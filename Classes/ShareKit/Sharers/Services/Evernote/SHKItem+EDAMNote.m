//
//  SHKItem+EDAMNote.m
//  ShareKit
//
//  Created by Atsushi Nagase on 3/22/11.
//  Copyright 2011 LittleApps Inc. All rights reserved.
//

#import "SHKItem+EDAMNote.h"
#import "SHKEvernote.h"
#import "SHK.h"
#import "Types.h"
#import "UserStore.h"
#import "NoteStore.h"
#import "NSData+md5.h"

@implementation SHKItem (EDAMNote)

- (EDAMNote *)edamNoteForNotebook:(EDAMNotebook *)notebook {
	SHKItem *item = self;
	SHKEvernoteItem *enItem = nil;
	NSMutableArray *resources = nil;
	EDAMNote *note = nil;
  
  if([item isKindOfClass:[SHKEvernoteItem class]]) {
    enItem = (SHKEvernoteItem *)item;
    note = enItem.note;
    resources = [note.resources mutableCopy];
  }
  
  if(!resources)
    resources = [[NSMutableArray alloc] init];
  if(!note)
    note = [[[EDAMNote alloc] init] autorelease];
		
  EDAMNoteAttributes *atr = [note attributesIsSet] ? [note.attributes retain] : [[EDAMNoteAttributes alloc] init];

  if(![atr sourceURLIsSet]&&enItem.URL)
    [atr setSourceURL:[enItem.URL absoluteString]];
  if(![note notebookGuidIsSet])
    [note setNotebookGuid:[notebook guid]];

  note.title = item.title.length > 0 ?
    item.title :
    ( [note titleIsSet] ?
          note.title :
          SHKLocalizedString(@"Untitled") );
  
  if(![note tagNamesIsSet]&&item.tags)
    [note setTagNames:[item.tags componentsSeparatedByString:@" "]];

  if(![note contentIsSet]) {
    NSMutableString* contentStr = [[NSMutableString alloc] initWithString:kENMLPrefix];
    NSString * strURL = [item.URL absoluteString];

    if(strURL.length>0) {
      if(item.title.length>0)
        [contentStr appendFormat:@"<h1><a href=\"%@\">%@</a></h1>",strURL,item.title];
      [contentStr appendFormat:@"<p><a href=\"%@\">%@</a></p>",strURL,strURL];
      atr.sourceURL = strURL;
    } else if(item.title.length>0)
      [contentStr appendFormat:@"<h1>%@</h1>",item.title];

    if(item.text.length>0 )
      [contentStr appendFormat:@"<p>%@</p>",item.text];

    if(item.image) {
      EDAMResource *img = [[[EDAMResource alloc] init] autorelease];
      NSData *rawimg = UIImageJPEGRepresentation(item.image, 0.6);
      EDAMData *imgd = [[[EDAMData alloc] initWithBodyHash:rawimg size:[rawimg length] body:rawimg] autorelease];
      [img setData:imgd];
      [img setRecognition:imgd];
      [img setMime:@"image/jpeg"];
      [resources addObject:img];
      [contentStr appendString:[NSString stringWithFormat:@"<p>%@</p>",[self enMediaTagWithResource:img width:item.image.size.width height:item.image.size.height]]];
    }

    if(item.data) {
      EDAMResource *file = [[[EDAMResource alloc] init] autorelease];	
      EDAMData *filed = [[[EDAMData alloc] initWithBodyHash:item.data size:[item.data length] body:item.data] autorelease];
      [file setData:filed];
      [file setRecognition:filed];
      [file setMime:item.mimeType];
      [resources addObject:file];
      [contentStr appendString:[NSString stringWithFormat:@"<p>%@</p>",[self enMediaTagWithResource:file width:0 height:0]]];
    }
    [contentStr appendString:kENMLSuffix];
    [note setContent:contentStr];
    [contentStr release];
  }
    
  ////////////////////////////////////////////////
  // Replace <img> HTML elements with en-media elements
  ////////////////////////////////////////////////

  for(EDAMResource *res in resources) {
    if(![res dataIsSet]&&[res attributesIsSet]&&res.attributes.sourceURL.length>0&&[res.mime isEqualToString:@"image/jpeg"]) {
      @try {
        NSData *rawimg = [NSData dataWithContentsOfURL:[NSURL URLWithString:res.attributes.sourceURL]];
        UIImage *img = [UIImage imageWithData:rawimg];
        if(img) {
          EDAMData *imgd = [[[EDAMData alloc] initWithBodyHash:rawimg size:[rawimg length] body:rawimg] autorelease];
          [res setData:imgd];
          [res setRecognition:imgd];
          [note setContent:
            [note.content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<img src=\"%@\" />",res.attributes.sourceURL]
                                                    withString:[self enMediaTagWithResource:res width:img.size.width height:img.size.height]]];
        }
      }
      @catch (NSException * e) {
        SHKLog(@"Caught: %@",e);
      }
    }
  }
  
  [note setCreated:(long long)[[NSDate date] timeIntervalSince1970] * 1000];
  [note setResources:resources];
  [note setAttributes:atr];
  [atr release];
  
  
  [resources release];
  
	
    
  return note;
}

- (NSString *)enMediaTagWithResource:(EDAMResource *)src width:(CGFloat)width height:(CGFloat)height {
	NSString *sizeAtr = width > 0 && height > 0 ? [NSString stringWithFormat:@"height=\"%.0f\" width=\"%.0f\" ",height,width]:@"";
	return [NSString stringWithFormat:@"<en-media type=\"%@\" %@hash=\"%@\"/>",src.mime,sizeAtr,[src.data.body md5]];
}


@end
