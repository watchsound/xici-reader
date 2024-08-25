//
//  XPathQuery.h
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//NSURL *tutorialsUrl = [NSURL URLWithString:@"http://www.raywenderlich.com/tutorials"];
//NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
//
//// 2
//TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
//
//// 3
//NSString *tutorialsXpathQueryString = @"//div[@class='content-wrapper']/ul/li/a";
//NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
//
//// 4
//NSMutableArray *newTutorials = [[NSMutableArray alloc] initWithCapacity:0];
//for (TFHppleElement *element in tutorialsNodes) {
//    // 5
//    Tutorial *tutorial = [[Tutorial alloc] init];
//    [newTutorials addObject:tutorial];
//    
//    // 6
//    tutorial.title = [[element firstChild] content];
//    
//    // 7
//    tutorial.url = [element objectForKey:@"href"];
//}
//
//// 8
//_objects = newTutorials;
//[self.tableView reloadData];

NSArray *PerformHTMLXPathQuery(NSData *document, NSString *query);
NSArray *PerformXMLXPathQuery(NSData *document, NSString *query);
