//
//  immerseReadDocument.h
//  immerseRead
//
//  Created by Sohei Okamoto on 11/13/13.
//  Copyright (c) 2013 Sohei Okamoto. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface immerseReadDocument : NSDocument

@property (unsafe_unretained) IBOutlet NSPopUpButton * _voicePopUpButton;
@property (strong) NSMutableArray *                    _voiceIdentifierList;
@property (unsafe_unretained) IBOutlet NSSlider *      _rateSlider;
@property (unsafe_unretained) IBOutlet NSSlider *      _volumeSlider;
@property (unsafe_unretained) IBOutlet NSSlider *      _pitchBaseSlider;
@property (unsafe_unretained) IBOutlet NSSlider *      _pitchModSlider;
@property (unsafe_unretained) IBOutlet NSTextField *   _rateTextField;
@property (unsafe_unretained) IBOutlet NSTextField *   _volumeTextField;
@property (unsafe_unretained) IBOutlet NSTextField *   _pitchBaseTextField;
@property (unsafe_unretained) IBOutlet NSTextField *   _pitchModTextField;

@property (unsafe_unretained) IBOutlet NSMatrix *      _stopModeMatrix;
@property (unsafe_unretained) IBOutlet NSButtonCell *  _immediatelyRadioButton;
@property (unsafe_unretained) IBOutlet NSButtonCell *  _afterWordRadioButton;
@property (unsafe_unretained) IBOutlet NSButtonCell *  _afterSentenceRadioButton;
                                                      
@property (unsafe_unretained) IBOutlet NSPopUpButton * _fontPopUpButton;
@property (strong) NSMutableArray *                    _fontIdentifierList;
@property (unsafe_unretained) IBOutlet NSSlider *      _fontSizeSlider;
@property (unsafe_unretained) IBOutlet NSTextField *   _fontSizeTextField;
@property (unsafe_unretained) IBOutlet NSColorWell *   _foregroundColorWell;
@property (unsafe_unretained) IBOutlet NSTextField *   _foregroundColorLabelTextField;
@property (unsafe_unretained) IBOutlet NSColorWell *   _backgroundColorWell;
@property (unsafe_unretained) IBOutlet NSTextField *   _backgroundColorLabelTextField;
@property (unsafe_unretained) IBOutlet NSButton *      _highlightWordCheckboxButton;
@property (unsafe_unretained) IBOutlet NSColorWell *   _highlightWordForegroundColorWell;
@property (unsafe_unretained) IBOutlet NSTextField *   _highlightWordForegroundColorLabelTextField;
@property (unsafe_unretained) IBOutlet NSColorWell *   _highlightWordBackgroundColorWell;
@property (unsafe_unretained) IBOutlet NSTextField *   _highlightWordBackgroundColorLabelTextField;
                                                      
@property (unsafe_unretained) IBOutlet NSButton *      _highlightSecondaryCheckboxButton;
@property (unsafe_unretained) IBOutlet NSColorWell *   _highlightSecondaryForegroundColorWell;
@property (unsafe_unretained) IBOutlet NSTextField *   _highlightSecondaryForegroundColorLabelTextField;
@property (unsafe_unretained) IBOutlet NSColorWell *   _highlightSecondaryBackgroundColorWell;
@property (unsafe_unretained) IBOutlet NSTextField *   _highlightSecondaryBackgroundColorLabelTextField;

@property (unsafe_unretained) IBOutlet NSMatrix *      _highlightModeMatrix;
@property (unsafe_unretained) IBOutlet NSButtonCell *  _highlightLineRadioButton;
@property (unsafe_unretained) IBOutlet NSButtonCell *  _highlightSentenceRadioButton;
@property (unsafe_unretained) IBOutlet NSButtonCell *  _highlightParagraphRadioButton;
@property (unsafe_unretained) IBOutlet NSButtonCell *  _highlightSurroundingWordsRadioButton;
                                                       
@property (unsafe_unretained) IBOutlet NSButton *      _startOrStopSpeakingButton;
@property (unsafe_unretained) IBOutlet NSButton *      _pauseOrContinueSpeakingButton;
@property (unsafe_unretained) IBOutlet NSButton *      _exportToFileButton;
                                                       
@property (unsafe_unretained) IBOutlet NSTextView *    _textView;
@property (strong) NSAttributedString *                _textViewString;
@property (strong) NSLayoutManager *                   _textViewLayoutManager;
                                                       
@property (strong) NSSpeechSynthesizer *               _speechSynthesizer;
                                                       
@property (strong) NSMutableDictionary *               _currentSettings;

@property NSUInteger                                   _offsetToSpokenText;
@property NSRange                                      _orgSelectionRange;
@property (strong) NSMutableDictionary *               _originalSelectedTextAttributes;
                                                       
@property NSRange                                      _currentSecondaryHighlightRange;

@property (strong) NSMutableArray *                    _sentenceEndLocations;
@property int                                          _sentenceEndLocationIndex;

@property (strong) NSMutableArray *                    _wordEndLocations;
@property int                                          _wordEndLocationIndex;

@property BOOL                                         _closing;


// Options panel actions
- (IBAction)resetSettings:(id)sender;

- (IBAction)voicePopupSelected:(id)sender;
- (IBAction)fontPopupSelected:(id)sender;
- (void)enableOptionsForSpeakingState:(BOOL)speakingNow;

// Parameters panel actions
- (IBAction)rateChanged:(id)sender;
- (IBAction)volumeChanged:(id)sender;
- (IBAction)pitchBaseChanged:(id)sender;
- (IBAction)pitchModChanged:(id)sender;
- (IBAction)stopModeChanged:(id)sender;
- (IBAction)resetSelected:(id)sender;
- (void)fillInEditableParameterFields;

- (IBAction)fontSizeChanged:(id)sender;
- (IBAction)foregroundColorChanged:(id)sender;
- (IBAction)backgroundColorChanged:(id)sender;
- (IBAction)highlightModeChanged:(id)sender;


- (IBAction)startOrStopSpeaking:(id)sender;
- (IBAction)pauseOrContinueSpeaking:(id)sender;
- (IBAction)exportToFile:(id)sender;
//- (IBAction)showOptions:(id)sender;
//- (IBAction)saveToFile:(id)sender;
//- (IBAction)savePhonemesToFile:(id)sender;
//- (IBAction)addDictionary:(id)sender;

@end
