//
//     ____    _                        __     _      _____
//    / ___\  /_\     /\/\    /\ /\    /__\   /_\     \_   \
//    \ \    //_\\   /    \  / / \ \  / \//  //_\\     / /\/
//  /\_\ \  /  _  \ / /\/\ \ \ \_/ / / _  \ /  _  \ /\/ /_
//  \____/  \_/ \_/ \/    \/  \___/  \/ \_/ \_/ \_/ \____/
//
//	Copyright Samurai development team and other contributors
//
//	http://www.samurai-framework.com
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

#import "Samurai_HtmlDocumentWorklet_40ParseStyleTree.h"

#import "_pragma_push.h"

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "Samurai_HtmlRenderObject.h"
#import "Samurai_HtmlRenderObjectContainer.h"
#import "Samurai_HtmlRenderObjectElement.h"
#import "Samurai_HtmlRenderObjectText.h"
#import "Samurai_HtmlRenderObjectViewport.h"

#import "Samurai_HtmlRenderStyle.h"
#import "Samurai_HtmlMediaQuery.h"

#import "Samurai_HtmlSharedResource.h"

#import "Samurai_CssParser.h"
#import "Samurai_CssStyleSheet.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation SamuraiHtmlDocumentWorklet_40ParseStyleTree

- (BOOL)processWithContext:(SamuraiHtmlDocument *)document
{
	if ( document.domTree )
	{
		[self parseDocument:document];
	}

	return YES;
}

- (void)parseDocument:(SamuraiDocument *)document
{
	document.styleTree = [SamuraiCssStyleSheet styleSheet];
	
// load default stylesheets
	
	for ( SamuraiStyleSheet * styleSheet in [SamuraiHtmlSharedResource sharedInstance].defaultStyleSheets )
	{
		BOOL isCompatible = [[SamuraiHtmlMediaQuery sharedInstance] test:styleSheet.media];
		if ( isCompatible )
		{
			[document.styleTree merge:styleSheet];
		}
	}

// load parent documents' stylesheets

	for ( SamuraiDocument * thisDocument = document; nil != thisDocument; thisDocument = (SamuraiDocument *)thisDocument.parent )
	{
		for ( SamuraiStyleSheet * styleSheet in [thisDocument.externalStylesheets copy] )
		{
			BOOL isCompatible = [[SamuraiHtmlMediaQuery sharedInstance] test:styleSheet.media];
			if ( isCompatible )
			{
				[document.styleTree merge:styleSheet];
			}
		}
	}

// parse sub documents

	for ( SamuraiResource * resource in [document.externalImports copy] )
	{
		if ( [resource isKindOfClass:[SamuraiDocument class]] )
		{
			[self parseDocument:(SamuraiDocument *)resource];
		}
	}
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#if __SAMURAI_TESTING__

TEST_CASE( UI, HtmlDocumentWorklet_40ParseStyleTree )
{
	//	TODO( @"test case" )
}
TEST_CASE_END

#endif	// #if __SAMURAI_TESTING__

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "_pragma_pop.h"
