//
//  SHKItem+EDAMNote.h
//  ShareKit
//
//  Created by Atsushi Nagase on 3/22/11.
//  Copyright 2011 LittleApps Inc. All rights reserved.
//

#import "SHKItem.h"

@class EDAMNote;
@class EDAMNotebook;
@class EDAMResource;
@interface SHKItem (EDAMNote)

- (EDAMNote *)edamNoteForNotebook:(EDAMNotebook *)notebook;
- (NSString *)enMediaTagWithResource:(EDAMResource *)src width:(CGFloat)width height:(CGFloat)height;

@end
