//
//  immerseReadDocument.m
//  immerseRead
//
//  Created by Sohei Okamoto on 11/13/13.
//  Copyright (c) 2013 Sohei Okamoto. All rights reserved.
//

#import "immerseReadDocument.h"

const NSUInteger numFixedMenuItemsPopup = 2;
const NSUInteger numSurroundingWords = 7;


@implementation immerseReadDocument

@synthesize _voicePopUpButton = voicePopUpButton;
@synthesize _voiceIdentifierList = voiceIdentifierList;
@synthesize _rateSlider = rateSlider;
@synthesize _volumeSlider = volumeSlider;
@synthesize _pitchBaseSlider = pitchBaseSlider;
@synthesize _pitchModSlider = pitchModSlider;
@synthesize _rateTextField = rateTextField;
@synthesize _volumeTextField = volumeTextField;
@synthesize _pitchBaseTextField = pitchBaseTextField;
@synthesize _pitchModTextField = pitchModTextField;
@synthesize _immediatelyRadioButton = immediatelyRadioButton;
@synthesize _afterWordRadioButton = afterWordRadioButton;
@synthesize _afterSentenceRadioButton = afterSentenceRadioButton;

@synthesize _fontPopUpButton = fontPopUpButton;
@synthesize _fontIdentifierList = fontIdentifierList;
@synthesize _fontSizeSlider = fontSizeSlider;
@synthesize _fontSizeTextField = fontSizeTextField;
@synthesize _foregroundColorWell = foregroundColorWell;
@synthesize _foregroundColorLabelTextField = foregroundColorLabelTextField;
@synthesize _backgroundColorWell = backgroundColorWell;
@synthesize _backgroundColorLabelTextField = backgroundColorLabelTextField;
@synthesize _highlightWordCheckboxButton = highlightWordCheckboxButton;
@synthesize _highlightWordForegroundColorWell = highlightWordForegroundColorWell;
@synthesize _highlightWordForegroundColorLabelTextField = highlightWordForegroundColorLabelTextField;
@synthesize _highlightWordBackgroundColorWell = highlightWordBackgroundColorWell;
@synthesize _highlightWordBackgroundColorLabelTextField = highlightWordBackgroundColorLabelTextField;

@synthesize _highlightSecondaryCheckboxButton = highlightSecondaryCheckboxButton;
@synthesize _highlightSecondaryForegroundColorWell = highlightSecondaryForegroundColorWell;
@synthesize _highlightSecondaryForegroundColorLabelTextField = highlightSecondaryForegroundColorLabelTextField;
@synthesize _highlightSecondaryBackgroundColorWell = highlightSecondaryBackgroundColorWell;
@synthesize _highlightSecondaryBackgroundColorLabelTextField = highlightSecondaryBackgroundColorLabelTextField;
@synthesize _highlightLineRadioButton = highlightLineRadioButton;
@synthesize _highlightSentenceRadioButton = highlightSentenceRadioButton;
@synthesize _highlightParagraphRadioButton = highlightParagraphRadioButton;
@synthesize _highlightSurroundingWordsRadioButton = highlightSurroundingWordsRadioButton;

@synthesize _startOrStopSpeakingButton = startOrStopSpeakingButton;
@synthesize _pauseOrContinueSpeakingButton = pauseOrContinueSpeakingButton;
@synthesize _exportToFileButton = exportToFileButton;

@synthesize _textView = textView;
@synthesize _textViewString = textViewString;
@synthesize _textViewLayoutManager = textViewLayoutManager;

@synthesize _speechSynthesizer = speechSynthesizer;

@synthesize _currentSettings = currentSettings;

@synthesize _offsetToSpokenText = offsetToSpokenText;
@synthesize _orgSelectionRange = orgSelectionRange;
@synthesize _originalSelectedTextAttributes = originalSelectedTextAttributes;

@synthesize _currentSecondaryHighlightRange = currentSecondaryHighlightRange;

@synthesize _sentenceEndLocations = sentenceEndLocations;
@synthesize _sentenceEndLocationIndex = sentenceEndLocationIndex;

@synthesize  _wordEndLocations = wordEndLocations;
@synthesize  _wordEndLocationIndex = wordEndLocationIndex;


- (id)init
{
    self = [super init];
    if( self )
    {
        // Add your subclass-specific initialization here.
        
        speechSynthesizer = [NSSpeechSynthesizer new];
        [speechSynthesizer setDelegate:self];
        
        currentSettings = [NSMutableDictionary new];
        [currentSettings setObject:[NSNumber numberWithLong:NSSpeechImmediateBoundary] forKey:@"NSSpeechBoundary"];
        [currentSettings setObject:[[NSFont userFontOfSize:-1] familyName] forKey:@"NSFontFamily"];
        [currentSettings setObject:[NSNumber numberWithBool:YES] forKey:@"NSTextViewHighlightWordCheckboxState"];
        [currentSettings setObject:@"HighlightLine" forKey:@"NSTextViewSecondaryHighlightMode"];

        sentenceEndLocations = [[NSMutableArray alloc] init];
        sentenceEndLocationIndex = -1;
        
        wordEndLocations = [[NSMutableArray alloc] init];
        wordEndLocationIndex = -1;
        
        self._closing = NO;
    }
    
    return self;
}


- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"immerseReadDocument";
}


- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    // Set up voices popup
    [self _updateVoicePopup];
    [voicePopUpButton selectItemAtIndex:0];
    
    // Set up fonts popup
    [self _updateFontPopup];
    [fontPopUpButton selectItemAtIndex:0];
    
    [startOrStopSpeakingButton setEnabled:true];
    [pauseOrContinueSpeakingButton setEnabled:false];
    
    [self _updateVoiceControls];
    
    [[textView window] makeFirstResponder: textView];
    
    [textView setAllowsUndo:YES];
    
    textView.string = @"";
    if( textViewString )
    {
        [textView insertText:textViewString];
    }
    
    [textView setSelectedRange:NSMakeRange(0, 0)];
    [textView scrollRangeToVisible:NSMakeRange(0, 0)];
    
    textViewLayoutManager = [textView layoutManager];
    
    originalSelectedTextAttributes = [textView.selectedTextAttributes mutableCopy];
}


+ (BOOL)autosavesInPlace
{
    return YES;
}


- (void)removeWindowController:(NSWindowController *)aController
{
    NSLog(@"immerseReadDocument::removeWindowController()");
    
    self._closing = YES;
    
    [speechSynthesizer stopSpeakingAtBoundary:NSSpeechImmediateBoundary];
    
    [super removeWindowController:aController];
}


/*
-(void)close
{
    NSLog(@"immerseReadDocument::close()");
  
    [super close];
}
*/


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    //NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    //@throw exception;
    //return nil;
    
    NSData *data;
    
    textViewString = [textView textStorage]; // Synchronize data model with the text storage
    
    //NSMutableDictionary *dict = [NSDictionary dictionaryWithObject:NSRTFTextDocumentType
    //                                                        forKey:NSDocumentTypeDocumentAttribute];
    
    [textView breakUndoCoalescing];
    
    //data = [self.mString dataFromRange:NSMakeRange(0, [self.mString length]) documentAttributes:dict error:outError];
    data = [textViewString.string dataUsingEncoding:NSUTF8StringEncoding];
             
    if( !data && outError )
    {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                        code:NSFileWriteUnknownError userInfo:nil];
    }
    
    return data;    
}


- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    //NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    //@throw exception;
    //return YES;
    
    BOOL readSuccess = NO;
    
    NSAttributedString *fileContents = [[NSAttributedString alloc]
                                        initWithData:data options:NULL documentAttributes:NULL
                                        error:outError];
    
    if( !fileContents && outError )
    {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                        code:NSFileReadUnknownError userInfo:nil];
    }
    
    if( fileContents )
    {
        readSuccess = YES;
        textViewString = fileContents;
    }
    
    return readSuccess;    
}


- (void)_setControlsEnabled:(BOOL)enabled
{
    [voicePopUpButton setEnabled:enabled];
    [rateSlider setEnabled:enabled];
    [volumeSlider setEnabled:enabled];
    [pitchBaseSlider setEnabled:enabled];
    [pitchModSlider setEnabled:enabled];
    [immediatelyRadioButton setEnabled:enabled];
    [afterWordRadioButton setEnabled:enabled];
    [afterSentenceRadioButton setEnabled:enabled];
    
    [fontPopUpButton setEnabled:enabled];
    [fontSizeSlider setEnabled:enabled];
    [foregroundColorWell setEnabled:enabled];
    [self _setLabelTextFieldEnabled:foregroundColorLabelTextField setEnabled:enabled];
    [backgroundColorWell setEnabled:enabled];
    [self _setLabelTextFieldEnabled:backgroundColorLabelTextField setEnabled:enabled];
    [highlightWordCheckboxButton setEnabled:enabled];
    [highlightWordForegroundColorWell setEnabled:enabled];
    [self _setLabelTextFieldEnabled:highlightWordForegroundColorLabelTextField setEnabled:enabled];
    [highlightWordBackgroundColorWell setEnabled:enabled];
    [self _setLabelTextFieldEnabled:highlightWordBackgroundColorLabelTextField setEnabled:enabled];
    
    [highlightSecondaryCheckboxButton setEnabled:enabled];
    [highlightSecondaryForegroundColorWell setEnabled:enabled];
    [self _setLabelTextFieldEnabled:highlightSecondaryForegroundColorLabelTextField setEnabled:enabled];
    [highlightSecondaryBackgroundColorWell setEnabled:enabled];
    [self _setLabelTextFieldEnabled:highlightSecondaryBackgroundColorLabelTextField setEnabled:enabled];
    [highlightLineRadioButton setEnabled:enabled];
    [highlightSentenceRadioButton setEnabled:enabled];
    [highlightParagraphRadioButton setEnabled:enabled];
    [highlightSurroundingWordsRadioButton setEnabled:enabled];
}


- (void)_setLabelTextFieldEnabled:(id)sender setEnabled:(BOOL)enabled
{
    if (enabled == NO)
    {
        [sender setTextColor:[NSColor disabledControlTextColor]];
    }
    else
    {
        [sender setTextColor:[NSColor controlTextColor]];
    }
}
 

- (void)_updateVoicePopup
{
    //[voiceIdentifierList release];
    voiceIdentifierList = [NSMutableArray new];
    
    // Delete any items in the voice menu
    while( [voicePopUpButton numberOfItems] > numFixedMenuItemsPopup )
    {
        [voicePopUpButton removeItemAtIndex:[voicePopUpButton numberOfItems] - 1];
    }
    
    NSString *aVoice = NULL;
    NSEnumerator *voiceEnumerator = [[NSSpeechSynthesizer availableVoices] objectEnumerator];
    while( aVoice = [voiceEnumerator nextObject] )
    {
        [voiceIdentifierList addObject:aVoice];
        [voicePopUpButton addItemWithTitle:[[NSSpeechSynthesizer attributesForVoice:aVoice] objectForKey:NSVoiceName]];
    }
}


- (void)_updateFontPopup
{
    //[fontIdentifierList release];
    fontIdentifierList = [NSMutableArray new];
    
    // Delete any items in the font menu
    while( [fontPopUpButton numberOfItems] > numFixedMenuItemsPopup )
    {
        [fontPopUpButton removeItemAtIndex:[fontPopUpButton numberOfItems] - 1];
    }
    
    fontIdentifierList = [[NSMutableArray alloc] initWithArray:[[NSFontManager sharedFontManager] availableFontFamilies]];
    [fontPopUpButton addItemsWithTitles:fontIdentifierList];
}


- (IBAction)voicePopupSelected:(id)sender
{
    NSLog(@"immerseReadDocument::voicePopupSelected()");
    
    [self _updateVoiceControls];
}


- (void)_updateVoiceControls
{
    if( [voicePopUpButton indexOfSelectedItem] >= numFixedMenuItemsPopup ) 
    {
        id voiceIdentifier = [voiceIdentifierList objectAtIndex:[voicePopUpButton indexOfSelectedItem] - numFixedMenuItemsPopup];
        if( voiceIdentifier ) 
        {
            [speechSynthesizer setVoice:voiceIdentifier];
        }
    }
    else 
    {
        [speechSynthesizer setVoice:[NSSpeechSynthesizer defaultVoice]];
    }

    [currentSettings setObject:[speechSynthesizer voice] forKey:@"NSSpeechVoice"];
    
    [speechSynthesizer setObject:NULL forProperty:NSSpeechResetProperty error:NULL];
    
    [rateSlider setFloatValue:[[speechSynthesizer objectForProperty:NSSpeechRateProperty error:NULL] floatValue]];
    [volumeSlider setFloatValue:[[speechSynthesizer objectForProperty:NSSpeechVolumeProperty error:NULL] floatValue]];
    [pitchBaseSlider setFloatValue:[[speechSynthesizer objectForProperty:NSSpeechPitchBaseProperty error:NULL] floatValue]];
    [pitchModSlider setFloatValue:[[speechSynthesizer objectForProperty:NSSpeechPitchModProperty error:NULL] floatValue]];

    [rateTextField setStringValue:[rateSlider stringValue]];
    [volumeTextField setStringValue:[volumeSlider stringValue]];
    [pitchBaseTextField setStringValue:[pitchBaseSlider stringValue]];
    [pitchModTextField setStringValue:[pitchModSlider stringValue]];
}


- (IBAction)rateChanged:(id)sender
{
    NSLog(@"immerseReadDocument::rateChanged()");
    
    [rateTextField setStringValue:[rateSlider stringValue]];
    
    [currentSettings setObject:[NSNumber numberWithFloat:[rateSlider floatValue]] forKey:NSSpeechRateProperty];
    [speechSynthesizer setObject:[currentSettings objectForKey:NSSpeechRateProperty] forProperty:NSSpeechRateProperty error:NULL];
}


- (IBAction)volumeChanged:(id)sender
{
    NSLog(@"immerseReadDocument::volumeChanged()");
    
    [volumeTextField setStringValue:[volumeSlider stringValue]];

    [currentSettings setObject:[NSNumber numberWithFloat:[volumeSlider floatValue]] forKey:NSSpeechVolumeProperty];
    [speechSynthesizer setObject:[currentSettings objectForKey:NSSpeechVolumeProperty] forProperty:NSSpeechVolumeProperty error:NULL];
}


- (IBAction)pitchBaseChanged:(id)sender
{
    NSLog(@"immerseReadDocument::pitchBaseChanged()");
    
    [pitchBaseTextField setStringValue:[pitchBaseSlider stringValue]];
    
    [currentSettings setObject:[NSNumber numberWithFloat:[pitchBaseSlider floatValue]] forKey:NSSpeechPitchBaseProperty];
    [speechSynthesizer setObject:[currentSettings objectForKey:NSSpeechPitchBaseProperty] forProperty:NSSpeechPitchBaseProperty error:NULL];
}


- (IBAction)pitchModChanged:(id)sender
{
    NSLog(@"immerseReadDocument::pitchModChanged()");
    
    [pitchModTextField setStringValue:[pitchModSlider stringValue]];

    [currentSettings setObject:[NSNumber numberWithFloat:[pitchModSlider floatValue]] forKey:NSSpeechPitchModProperty];
    [speechSynthesizer setObject:[currentSettings objectForKey:NSSpeechPitchModProperty] forProperty:NSSpeechPitchModProperty error:NULL];
}


- (IBAction)fontPopupSelected:(id)sender
{
    NSLog(@"immerseReadDocument::fontPopupSelected()");
       
    if( [fontPopUpButton indexOfSelectedItem] >= numFixedMenuItemsPopup ) 
    {
        id fontIdentifier = [fontIdentifierList objectAtIndex:[fontPopUpButton indexOfSelectedItem] - numFixedMenuItemsPopup];
        if( fontIdentifier ) 
        {
            [currentSettings setObject:fontIdentifier forKey:@"NSFontFamily"];
        }
    }
    else 
    {
        NSFont *font = [NSFont userFontOfSize:-1];
        [currentSettings setObject:font.familyName forKey:@"NSFontFamily"];
    }
        
    id font_family = [currentSettings objectForKey:@"NSFontFamily"];
    id font_size = [currentSettings objectForKey:@"NSFontSize"];
    [textView setFont:[NSFont fontWithName:font_family size:[font_size floatValue]]];
}


- (IBAction)fontSizeChanged:(id)sender
{
    NSLog(@"immerseReadDocument::fontSizeChanged()");
       
    [fontSizeTextField setStringValue:[fontSizeSlider stringValue]];
       
    [currentSettings setObject:[NSNumber numberWithFloat:[fontSizeSlider floatValue]] forKey:@"NSFontSize"];
       
    id font_family = [currentSettings objectForKey:@"NSFontFamily"];
    id font_size = [currentSettings objectForKey:@"NSFontSize"];
    [textView setFont:[NSFont fontWithName:font_family size:[font_size floatValue]]];
}


- (IBAction)foregroundColorChanged:(id)sender
{
    NSLog(@"immerseReadDocument::foregroundColorChanged()");
       
    [currentSettings setObject:foregroundColorWell.color forKey:@"NSTextViewForegroundColor"];
    
    id foreground_color = [currentSettings objectForKey:@"NSTextViewForegroundColor"];
    [textView setTextColor:foreground_color];
}


- (IBAction)backgroundColorChanged:(id)sender
{
    NSLog(@"immerseReadDocument::backgroundColorChanged()");
       
    [currentSettings setObject:backgroundColorWell.color forKey:@"NSTextViewBackgroundColor"];

    id background_color = [currentSettings objectForKey:@"NSTextViewBackgroundColor"];
    [textView setBackgroundColor:background_color];
}


- (void)_updateSettings
{
    NSLog(@"immerseReadDocument::_updateSettings()");
    
    if( [rateSlider isEnabled] ) 
    {
        [currentSettings setObject:[NSNumber numberWithFloat:[rateSlider floatValue]] forKey:NSSpeechRateProperty];
    }
    
    if( [volumeSlider isEnabled] ) 
    {
        [currentSettings setObject:[NSNumber numberWithFloat:[volumeSlider floatValue]] forKey:NSSpeechVolumeProperty];
    }
    
    if( [pitchBaseSlider isEnabled] ) 
    {
        [currentSettings setObject:[NSNumber numberWithFloat:[pitchBaseSlider floatValue]] forKey:NSSpeechPitchBaseProperty];
    }
    
    if( [pitchModSlider isEnabled] ) 
    {
        [currentSettings setObject:[NSNumber numberWithFloat:[pitchModSlider floatValue]] forKey:NSSpeechPitchModProperty];
    }
    
    if( [fontSizeSlider isEnabled] ) 
    {
        [currentSettings setObject:[NSNumber numberWithFloat:[fontSizeSlider floatValue]] forKey:@"NSFontSize"];
    }
    
    if( [foregroundColorWell isEnabled] ) 
    {
        [currentSettings setObject:foregroundColorWell.color forKey:@"NSTextViewForegroundColor"];
        [foregroundColorWell deactivate];
    }
    
    if( [backgroundColorWell isEnabled] ) 
    {
        [currentSettings setObject:backgroundColorWell.color forKey:@"NSTextViewBackgroundColor"];
        [backgroundColorWell deactivate];
    }
    
    if( [highlightWordCheckboxButton isEnabled] ) 
    {
        BOOL state = NO;
        if( [highlightWordCheckboxButton state] == NSOnState )
        {
            state = YES;
        }
        
        [currentSettings setObject:[NSNumber numberWithBool:state] forKey:@"NSTextViewHighlightWordCheckboxState"];
    }
    
    if( [highlightWordForegroundColorWell isEnabled] ) 
    {
        [currentSettings setObject:highlightWordForegroundColorWell.color forKey:@"NSTextViewHighlightWordForegroundColor"];
        [highlightWordForegroundColorWell deactivate];
    }
    
    if( [highlightWordBackgroundColorWell isEnabled] ) 
    {
        [currentSettings setObject:highlightWordBackgroundColorWell.color forKey:@"NSTextViewHighlightWordBackgroundColor"];
        [highlightWordBackgroundColorWell deactivate];
    }
    
    if( [highlightSecondaryCheckboxButton isEnabled] ) 
    {
        BOOL state = NO;
        if( [highlightSecondaryCheckboxButton state] == NSOnState )
        {
            state = YES;
        }
        
        [currentSettings setObject:[NSNumber numberWithBool:state] forKey:@"NSTextViewHighlightSecondaryCheckboxState"];
    }
    
    if( [highlightSecondaryForegroundColorWell isEnabled] ) 
    {
        [currentSettings setObject:highlightSecondaryForegroundColorWell.color forKey:@"NSTextViewHighlightSecondaryForegroundColor"];
        [highlightSecondaryForegroundColorWell deactivate];
    }
    
    if( [highlightSecondaryBackgroundColorWell isEnabled] ) 
    {
        [currentSettings setObject:highlightSecondaryBackgroundColorWell.color forKey:@"NSTextViewHighlightSecondaryBackgroundColor"];
        [highlightSecondaryBackgroundColorWell deactivate];
    }
    
    if( [highlightLineRadioButton isEnabled] && [highlightSentenceRadioButton isEnabled] && [highlightParagraphRadioButton isEnabled]  && [highlightSurroundingWordsRadioButton isEnabled] )
    {
        if( [highlightLineRadioButton intValue] )
        {
            [currentSettings setObject:@"HighlightLine" forKey:@"NSTextViewSecondaryHighlightMode"];
        }
        else if( [highlightSentenceRadioButton intValue] )
        {
            [currentSettings setObject:@"HighlightSentence" forKey:@"NSTextViewSecondaryHighlightMode"];
        }
        else if( [highlightParagraphRadioButton intValue] )
        {
            [currentSettings setObject:@"HighlightParagraph" forKey:@"NSTextViewSecondaryHighlightMode"];
        }
        else if( [highlightSurroundingWordsRadioButton intValue] )
        {
            [currentSettings setObject:@"HighlightSurroundingWords" forKey:@"NSTextViewSecondaryHighlightMode"];
        }
    }
    
    if( [voicePopUpButton isEnabled] ) 
    {
        if( [voicePopUpButton indexOfSelectedItem] >= numFixedMenuItemsPopup ) 
        {
            id voiceIdentifier = [voiceIdentifierList objectAtIndex:[voicePopUpButton indexOfSelectedItem] - numFixedMenuItemsPopup];
            if( voiceIdentifier ) 
            {
                [currentSettings setObject:voiceIdentifier forKey:@"NSSpeechVoice"];
            }
        }
        else 
        {
            [currentSettings setObject:[NSSpeechSynthesizer defaultVoice] forKey:@"NSSpeechVoice"];
        }
    }
    
    if( [fontPopUpButton isEnabled] )
    {
        if( [fontPopUpButton indexOfSelectedItem] >= numFixedMenuItemsPopup ) 
        {
            id fontIdentifier = [fontIdentifierList objectAtIndex:[fontPopUpButton indexOfSelectedItem] - numFixedMenuItemsPopup];
            if( fontIdentifier ) 
            {
                [currentSettings setObject:fontIdentifier forKey:@"NSFontFamily"];
            }
        }
        else 
        {
            NSFont *font = [NSFont userFontOfSize:-1];
            [currentSettings setObject:font.familyName forKey:@"NSFontFamily"];
        }
    }
    
    if( [immediatelyRadioButton isEnabled] && [afterWordRadioButton isEnabled] && [afterSentenceRadioButton isEnabled] ) 
    {
        if( [immediatelyRadioButton intValue] ) 
        {
            [currentSettings setObject:[NSNumber numberWithLong:NSSpeechImmediateBoundary] forKey:@"NSSpeechBoundary"];
        }
        else if( [afterWordRadioButton intValue] ) 
        {
            [currentSettings setObject:[NSNumber numberWithLong:NSSpeechWordBoundary] forKey:@"NSSpeechBoundary"];
        }
        else if( [afterSentenceRadioButton intValue] ) 
        {
            [currentSettings setObject:[NSNumber numberWithLong:NSSpeechSentenceBoundary] forKey:@"NSSpeechBoundary"];
        }
    }

    
    NSString *key = NULL;
    NSEnumerator *settingsEnumerator = [currentSettings keyEnumerator];
    while(key = [settingsEnumerator nextObject])
    {
        NSLog(@"currentSettings key: %@, value: %@", key, [currentSettings objectForKey:key]);
        
        [speechSynthesizer setObject:[currentSettings objectForKey:key] forProperty:key error:NULL];
    }
    
    [speechSynthesizer setVoice:[currentSettings objectForKey:@"NSSpeechVoice"]];
    
    [speechSynthesizer setObject:[currentSettings objectForKey:NSSpeechRateProperty] forProperty:NSSpeechRateProperty error:NULL];
    [speechSynthesizer setObject:[currentSettings objectForKey:NSSpeechVolumeProperty] forProperty:NSSpeechVolumeProperty error:NULL];
    [speechSynthesizer setObject:[currentSettings objectForKey:NSSpeechPitchBaseProperty] forProperty:NSSpeechPitchBaseProperty error:NULL];
    [speechSynthesizer setObject:[currentSettings objectForKey:NSSpeechPitchModProperty] forProperty:NSSpeechPitchModProperty error:NULL];
            
    // REDUNDANT CODE (WITH ON-CHANGED)
    id font_family = [currentSettings objectForKey:@"NSFontFamily"];
    id font_size = [currentSettings objectForKey:@"NSFontSize"];
    [textView setFont:[NSFont fontWithName:font_family size:[font_size floatValue]]];
    
    id foreground_color = [currentSettings objectForKey:@"NSTextViewForegroundColor"];
    [textView setTextColor:foreground_color];
    
    id background_color = [currentSettings objectForKey:@"NSTextViewBackgroundColor"];
    [textView setBackgroundColor:background_color];
}


- (IBAction)startOrStopSpeaking:(id)sender
{
    NSLog(@"immerseReadDocument::startOrStopSpeaking()");
    
    [self _startSpeakingTextViewToURL:NULL];
}


- (IBAction)pauseOrContinueSpeaking:(id)sender
{
    NSLog(@"immerseReadDocument::pauseOrContinueSpeaking()");
       
    if( [[[speechSynthesizer objectForProperty:NSSpeechStatusProperty error:NULL] objectForKey:NSSpeechStatusOutputPaused] integerValue] )
    {
        [speechSynthesizer continueSpeaking];
        
        [pauseOrContinueSpeakingButton setTitle:NSLocalizedString(@"Pause Speaking", @"Pausing button name (pause)")];

        NSLog(@"Did continue speaking");
        
    }
    else if( [speechSynthesizer isSpeaking] )
    {
        [speechSynthesizer pauseSpeakingAtBoundary:[[currentSettings objectForKey:@"NSSpeechBoundary"] intValue]];
     
        [pauseOrContinueSpeakingButton setTitle:NSLocalizedString(@"Continue Speaking", @"Pausing button name (continue)")];
        
        NSLog(@"Did stop speaking");
    }
}


- (IBAction)exportToFile:(id)sender
{
    NSLog(@"immerseReadDocument::exportToFile()");
    
    NSURL *selected_file_url = NULL;
    
    NSSavePanel *save_panel = [NSSavePanel savePanel];
    
    [save_panel setPrompt:NSLocalizedString(@"Save", @"Save")];
    [save_panel setNameFieldStringValue:@"Untitled.aiff"];
    
    if( [save_panel runModal] == NSFileHandlingPanelOKButton )
    {
        selected_file_url = [save_panel URL];
        [self _startSpeakingTextViewToURL:selected_file_url];
    }
}


- (void)_startSpeakingTextViewToURL:(NSURL *)url
{
    NSLog(@"immerseReadDocument::_startSpeakingTextViewToURL");
    
    // If speaking or paused, then stop it.
    if([speechSynthesizer isSpeaking] || [[[speechSynthesizer objectForProperty:NSSpeechStatusProperty error:NULL] objectForKey:NSSpeechStatusOutputPaused] intValue])
    {
        [speechSynthesizer stopSpeakingAtBoundary:[[currentSettings objectForKey:@"NSSpeechBoundary"] intValue]];
    }
    else
    {
        // Grab the selection substring, or if no selection then grab entire text.
        orgSelectionRange = [textView selectedRange];
        
        NSLog(@"textView.string.length: %d", textView.string.length);

        NSLog(@"orgSelectionRange (%d, %d)", orgSelectionRange.location, orgSelectionRange.length);
        
        NSString *theViewText;
        if( orgSelectionRange.length == 0 )
        {
            //theViewText = [textView string];
            //offsetToSpokenText = 0;

            if( orgSelectionRange.location == textView.string.length )
            {
                orgSelectionRange.location = 0;
            }

            //orgSelectionRange.length = [[textView string] length] - orgSelectionRange.location;
            theViewText = [[textView string] substringWithRange:NSMakeRange(orgSelectionRange.location, [[textView string] length] - orgSelectionRange.location)];
            offsetToSpokenText = orgSelectionRange.location;

        }
        else
        {
            theViewText = [[textView string] substringWithRange:orgSelectionRange];
            offsetToSpokenText = orgSelectionRange.location;
        }
        
        NSLog(@"Starting to speak: %@", theViewText);
        
        [self _updateSettings];
        
        if( url )
        {
            //synthesize text into a sound (AIFF) file.
            [speechSynthesizer startSpeakingString:theViewText toURL:url];
            //[startOrStopSpeakingButton setEnabled:NO];
        }
        else
        {
            id highlight_word_foreground_color = [currentSettings objectForKey:@"NSTextViewHighlightWordForegroundColor"];
            if( !highlight_word_foreground_color )
            {
                highlight_word_foreground_color = [originalSelectedTextAttributes objectForKey:NSForegroundColorAttributeName];
            }
            
            id highlight_word_background_color = [currentSettings objectForKey:@"NSTextViewHighlightWordBackgroundColor"];
            if( !highlight_word_background_color )
            {
                highlight_word_background_color = [originalSelectedTextAttributes objectForKey:NSBackgroundColorAttributeName];
            }
            
            [textView setSelectedTextAttributes:
                [NSDictionary dictionaryWithObjectsAndKeys:
                    highlight_word_foreground_color, NSForegroundColorAttributeName,
                    highlight_word_background_color, NSBackgroundColorAttributeName,
                    nil]];
            
            id highlight_secondary = [currentSettings objectForKey:@"NSTextViewHighlightSecondaryCheckboxState"];
            if( highlight_secondary && [highlight_secondary boolValue] == YES )
            {
                NSLog(@"Highlight Secondary: %@", [currentSettings objectForKey:@"NSTextViewSecondaryHighlightMode"]);
              
                if( [currentSettings objectForKey:@"NSTextViewSecondaryHighlightMode"] == @"HighlightLine" )
                {        
                    // get current line range
                    (void) [textViewLayoutManager lineFragmentRectForGlyphAtIndex:orgSelectionRange.location effectiveRange:&currentSecondaryHighlightRange];
                    
                    [self updateSecondaryHighlight:NSMakeRange(0, 0) newRange:currentSecondaryHighlightRange];
                }
                else if( [currentSettings objectForKey:@"NSTextViewSecondaryHighlightMode"] == @"HighlightSentence" )
                {
                    NSArray *sentence_terminators = [NSArray arrayWithObjects:@". ", @"? ", @": ", @"\n", nil];
                    [self _initializeEndLocations:&sentenceEndLocations terminators:sentence_terminators];
                    
                    //for( id location in sentenceEndLocations )
                    //{
                    //    NSLog(@"location: %@", location);
                    //}
                    
                    // initialize current location to optimize search
                    sentenceEndLocationIndex = 1;
                    
                    // get current sentence range
                    currentSecondaryHighlightRange = [self _sentenceRangeAtLocation:orgSelectionRange.location index:&sentenceEndLocationIndex];
                    
                    [self updateSecondaryHighlight:NSMakeRange(0, 0) newRange:currentSecondaryHighlightRange];
                }
                else if( [currentSettings objectForKey:@"NSTextViewSecondaryHighlightMode"] == @"HighlightParagraph" )
                {
                    // get current paragraph range
                    currentSecondaryHighlightRange = [textView.string lineRangeForRange:NSMakeRange(orgSelectionRange.location, 0)];
            
                    [self updateSecondaryHighlight:NSMakeRange(0, 0) newRange:currentSecondaryHighlightRange];                          
                }
                else if( [currentSettings objectForKey:@"NSTextViewSecondaryHighlightMode"] == @"HighlightSurroundingWords" )
                {
                    NSArray *word_terminators = [NSArray arrayWithObjects:@" ", @"\n", nil];
                    [self _initializeEndLocations:&wordEndLocations terminators:word_terminators];
                    
                    //for( id location in wordEndLocations )
                    //{
                    //    NSLog(@"location: %@", location);
                    //}
                    
                    // initialize current location to optimize search
                    wordEndLocationIndex = 1;
                    
                    // get current surrounding words range
                    currentSecondaryHighlightRange = [self _surroundingWordsRangeAtLocation:orgSelectionRange.location index:&wordEndLocationIndex];
                    
                    [self updateSecondaryHighlight:NSMakeRange(0, 0) newRange:currentSecondaryHighlightRange];
                }
            }
            
            // Update button states if we start speaking successfully
            if( [speechSynthesizer startSpeakingString:theViewText] )
            {
                [self _setControlsEnabled:NO];
                [pauseOrContinueSpeakingButton setEnabled:YES];
                [fontPopUpButton setEnabled:YES];
                [fontSizeSlider setEnabled:YES];
                
                [rateSlider setEnabled:YES];
                [volumeSlider setEnabled:YES];
                [pitchBaseSlider setEnabled:YES];
                [pitchModSlider setEnabled:YES];
                
                [startOrStopSpeakingButton setTitle:NSLocalizedString(@"Stop Speaking", @"Speaking button name (stop)")];
                [pauseOrContinueSpeakingButton setTitle:NSLocalizedString(@"Pause Speaking", @"Pausing button name (pause)")];
            }
        }
    }
}


- (void)updateSecondaryHighlight:(NSRange)old_range newRange:(NSRange)new_range
{
      // reset color for previous line
      [textViewLayoutManager removeTemporaryAttribute:NSForegroundColorAttributeName 
            forCharacterRange:old_range];
            
      [textViewLayoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName 
            forCharacterRange:old_range];
            
      [textViewLayoutManager addTemporaryAttribute:NSForegroundColorAttributeName 
            value:[currentSettings objectForKey:@"NSTextViewHighlightSecondaryForegroundColor"]
            forCharacterRange:new_range];
            
      [textViewLayoutManager addTemporaryAttribute:NSBackgroundColorAttributeName 
            value:[currentSettings objectForKey:@"NSTextViewHighlightSecondaryBackgroundColor"]
            forCharacterRange:new_range];
}


- (void)_initializeEndLocations:(NSMutableArray * __strong *)end_locations terminators:(NSArray *)terminators
{
    [(*end_locations) removeAllObjects];

    [(*end_locations) addObject:[NSNumber numberWithInt:(0)]];
    
    NSString *string = textView.string;
    int string_length = [string length];
    
    for( NSString *terminator in terminators )
    {
        NSRange range = NSMakeRange(0, 0);
        while( range.location != NSNotFound )
        {
            NSUInteger start = range.location + range.length;
            NSUInteger length = string_length - start;
            range = [string rangeOfString:terminator options:0 range:NSMakeRange(start, length)];
            
            //NSLog(@"range of '%@' (%d, %d)", terminator, range.location, range.length);
            
            if( range.location != NSNotFound )
            {
                NSNumber* location = [NSNumber numberWithInt:(range.location + range.length)];
                [(*end_locations) addObject:location];
            }
        }
    }
    
    [(*end_locations) sortUsingSelector:@selector(compare:)];
    
    if( [[(*end_locations) lastObject] intValue] != string_length )
    {
        NSNumber* location = [NSNumber numberWithInt:string_length];
        [(*end_locations) addObject:location];
    }
}


// Search the sentence at the location from the index (also update the index, too). Returns sentence range.
- (NSRange)_sentenceRangeAtLocation:(int)location index:(int *)sentence_end_location_index 
{
    while( location >= [[sentenceEndLocations objectAtIndex:(*sentence_end_location_index)] intValue] && (*sentence_end_location_index) < [sentenceEndLocations count])
    {
        //NSLog(@"Searching sentenceEndLocations[%d]: %d", (*sentence_end_location_index), [[sentenceEndLocations objectAtIndex:(*sentence_end_location_index)] intValue]);
        
        ++(*sentence_end_location_index);
    }

    //NSLog(@"sentenceEndLocations[%d]: %d", (*sentence_end_location_index), [[sentenceEndLocations objectAtIndex:(*sentence_end_location_index)] intValue]);
    
    int sentence_start = [[sentenceEndLocations objectAtIndex:(*sentence_end_location_index)-1] intValue];
    int sentence_end = [[sentenceEndLocations objectAtIndex:(*sentence_end_location_index)] intValue];
    
    return NSMakeRange(sentence_start, sentence_end - sentence_start);
}


// search the word at the location from the index (also update the index, too). Returns surrouding words range.
- (NSRange)_surroundingWordsRangeAtLocation:(int)location index:(int *)word_end_location_index 
{
    while( location >= [[wordEndLocations objectAtIndex:(*word_end_location_index)] intValue] && (*word_end_location_index) < [wordEndLocations count])
    {
        //NSLog(@"Searching wordEndLocations[%d]: %d", (*word_end_location_index), [[wordEndLocations objectAtIndex:(*word_end_location_index)] intValue]);
        
        ++(*word_end_location_index);
    }
    
    //NSLog(@"wordEndLocations[%d]: %d", (*word_end_location_index), [[wordEndLocations objectAtIndex:(*word_end_location_index)] intValue]);
    
    int surrounding_words_start_index = (*word_end_location_index) - numSurroundingWords - 1;
    int surrounding_words_end_index = (*word_end_location_index) + numSurroundingWords;
    
    if( surrounding_words_start_index < 0 )
    {
        surrounding_words_start_index = 0;
    }
    
    if( surrounding_words_end_index >= [wordEndLocations count] )
    {
        surrounding_words_end_index = [wordEndLocations count] - 1;
    }
    
    int surrounding_words_start = [[wordEndLocations objectAtIndex:surrounding_words_start_index] intValue];
    int surrounding_words_end = [[wordEndLocations objectAtIndex:surrounding_words_end_index] intValue];
                      
    return NSMakeRange(surrounding_words_start, surrounding_words_end - surrounding_words_start);
}
                    
                          
#pragma mark Callback Handlers
- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender willSpeakPhoneme:(short)phonemeOpcode
{
    //NSLog(@"Will speak phoneme: %d", phonemeOpcode);
}


- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender willSpeakWord:(NSRange)characterRange ofString:(NSString *)string
{
    NSLog(@"willSpeakWord: %@", [string substringWithRange:characterRange]);
    
    // make sure it is still speaking
    if( [speechSynthesizer isSpeaking] )
    {
        NSUInteger selectionPosition = characterRange.location + offsetToSpokenText;
        NSUInteger wordLength = characterRange.length;
    
        NSRange word_range = NSMakeRange(selectionPosition, wordLength);
        
        NSLog(@"word_range (%d, %d)", word_range.location, word_range.length);
    
        id highlight_word = [currentSettings objectForKey:@"NSTextViewHighlightWordCheckboxState"];
        if( highlight_word && [highlight_word boolValue] == YES )
        {
            [textView scrollRangeToVisible:word_range];
            [textView setSelectedRange:word_range];
            [textView display];
        }
        
        id highlight_secondary = [currentSettings objectForKey:@"NSTextViewHighlightSecondaryCheckboxState"];
        if( highlight_secondary && [highlight_secondary boolValue] == YES )
        {
            if( [currentSettings objectForKey:@"NSTextViewSecondaryHighlightMode"] == @"HighlightLine" )
            {
                NSLog(@"current line range: (%d, %d)", currentSecondaryHighlightRange.location, currentSecondaryHighlightRange.length);
                
                NSRange next_line_range;
                
                // get current line range
                (void) [textViewLayoutManager lineFragmentRectForGlyphAtIndex:word_range.location effectiveRange:&next_line_range];
                
                if( next_line_range.location > currentSecondaryHighlightRange.location )
                {
                    NSLog(@"next_line_range: (%d, %d)", next_line_range.location, next_line_range.length);
                
                    [self updateSecondaryHighlight:currentSecondaryHighlightRange newRange:next_line_range];
                    
                    currentSecondaryHighlightRange = next_line_range;
                }
            }
            else if( [currentSettings objectForKey:@"NSTextViewSecondaryHighlightMode"] == @"HighlightSentence" )
            {
                NSLog(@"sentenceEndLocations[%d]: %d", sentenceEndLocationIndex, [[sentenceEndLocations objectAtIndex:sentenceEndLocationIndex] intValue]);
                
                if( word_range.location >= [[sentenceEndLocations objectAtIndex:sentenceEndLocationIndex] intValue] )
                {
                    // get current sentence range
                    NSRange next_sentence_range = [self _sentenceRangeAtLocation:word_range.location index:&sentenceEndLocationIndex];
                    
                    NSLog(@"new sentenceEndLocations[%d]: %d", sentenceEndLocationIndex, [[sentenceEndLocations objectAtIndex:sentenceEndLocationIndex] intValue]);
                    
                    [self updateSecondaryHighlight:currentSecondaryHighlightRange newRange:next_sentence_range];
                    
                    currentSecondaryHighlightRange = next_sentence_range;
                }
            }
            else if( [currentSettings objectForKey:@"NSTextViewSecondaryHighlightMode"] == @"HighlightParagraph" )
            {
                NSLog(@"current paragraph range: (%d, %d)", currentSecondaryHighlightRange.location, currentSecondaryHighlightRange.length);
                
                // get current paragraph range
                NSRange next_paragraph_range = [textView.string lineRangeForRange:word_range];
                
                if( next_paragraph_range.location > currentSecondaryHighlightRange.location )
                {
                    NSLog(@"next_paragraph_range: (%d, %d)", next_paragraph_range.location, next_paragraph_range.length);
                
                    [self updateSecondaryHighlight:currentSecondaryHighlightRange newRange:next_paragraph_range];
                    
                    currentSecondaryHighlightRange = next_paragraph_range;
                }
            }
            else if( [currentSettings objectForKey:@"NSTextViewSecondaryHighlightMode"] == @"HighlightSurroundingWords" )
            {
                NSLog(@"current wordEndLocations[%d]: %d", wordEndLocationIndex, [[wordEndLocations objectAtIndex:wordEndLocationIndex] intValue]);
                
                if( word_range.location >= [[wordEndLocations objectAtIndex:wordEndLocationIndex] intValue] )
                {
                    // get current surrounding words range
                    NSRange next_surrounding_words_range = [self _surroundingWordsRangeAtLocation:word_range.location index:&wordEndLocationIndex];
                    
                    NSLog(@"new wordEndLocations[%d]: %d", wordEndLocations, [[wordEndLocations objectAtIndex:wordEndLocationIndex] intValue]);
                    
                    [self updateSecondaryHighlight:currentSecondaryHighlightRange newRange:next_surrounding_words_range];
                    
                    currentSecondaryHighlightRange = next_surrounding_words_range;                          
                }
            }
        }
    }
}


- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)finishedSpeaking
{
    NSLog(@"didFinishSpeaking: finishedSpeaking: %d", finishedSpeaking);
    
    if( !self._closing )
    {
        // Update button states
        [self _setControlsEnabled:YES];
        [pauseOrContinueSpeakingButton setEnabled:NO];
        
        [startOrStopSpeakingButton setTitle:NSLocalizedString(@"Start Speaking", @"Speaking button name (start)")];
        [pauseOrContinueSpeakingButton setTitle:NSLocalizedString(@"Pause Speaking", @"Pausing button name (pause)")];
    
        if( finishedSpeaking )
        {
            NSLog(@"Speaking finished");
        }
        else
        {
            NSLog(@"Speaking was stopped");
        }
        
        [textViewLayoutManager removeTemporaryAttribute:NSForegroundColorAttributeName 
              forCharacterRange:NSMakeRange(0, [textView.string length])];
              
        [textViewLayoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName 
              forCharacterRange:NSMakeRange(0, [textView.string length])];
              
        // reset the text color
        //id foreground_color = [currentSettings objectForKey:@"NSTextViewForegroundColor"];
        //[textView setTextColor:foreground_color];
        
        [textView setSelectedTextAttributes:originalSelectedTextAttributes];
        [textView setSelectedRange:orgSelectionRange];
    }
}


- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didEncounterErrorAtIndex:(NSUInteger)characterIndex ofString:(NSString *)string message:(NSString *)message;
{
    NSLog(@"Encountered error: %@", message);
}


- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didEncounterSyncMessage:(NSString *)message
{
    NSLog(@"Encountered sync message: %@", message);
}

@end
