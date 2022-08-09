@isTest
global class YouTubeBatchClass_Test {
    
    
    
    global class searchCalloutMock implements HttpCalloutMock{
        global HttpResponse respond(HTTPRequest req){          
            
            httprequest httpReq =new httprequest();
            httpReq.setEndpoint('https://youtube.googleapis.com/youtube/v3/search?part=snippet&channelId=UC8vzBnByif4adVQr7Vij7SQ&fields=pageInfo%2CnextPageToken%2Citems(id(videoId))&key=abcd');
            httpReq.setMethod('GET');
            
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);            
            // res.setBody('{'+'\"nextPageToken\":\"",'+'\"pageInfo\":{'+'\"totalResults\":5,'+'\"resultsPerPage\":5'+'},'+'\"items\":['+'{'+'\"id\":{}'+'},'+'{'+'\"id\":{}'+'},'+'{'+'\"id\":{'+'\"videoId\":\"ySb7PyCF3QY\"'+'}'+'},'+'{'+'\"id\":{'+'\"videoId\":\"CbuJW-hn6eo\"'+'}'+'},'+'{'+'\"id\":{'+'\"videoId\":\"FVZFoWMwg6I\"'+'}'+'}'+']'+'}');
            res.setBody('{'+'\"nextPageToken\":\"\",'+'\"pageInfo\":{'+'\"totalResults\":5,'+'\"resultsPerPage\":5'+'},'+'\"items\":['+'{'+'\"id\":{'+'\"videoId\":\"THb9WBNGi58\"'+'}'+'},'+'{'+'\"id\":{'+'\"videoId\":\"4KLyiEH7JCI\"'+'}'+'},'+'{'+'\"id\":{'+'\"videoId\":\"ySb7PyCF3QY\"'+'}'+'},'+'{'+'\"id\":{'+'\"videoId\":\"CbuJW-hn6eo\"'+'}'+'},'+'{'+'\"id\":{'+'\"videoId\":\"FVZFoWMwg6I\"'+'}'+'}'+']'+'}');
            return res;                                                
        }               
    }    
    static testMethod void searchTest() {
        
        List<API_Settings__c> apiSettingsList = new List<API_Settings__c>();                
        apiSettingsList.add(New API_Settings__c(Name = 'YouTube API Key',value__c='AIzaSyC_TyKcaLcY99jIu4kLPJd4rwg1MrtNZ6Q'));
        apiSettingsList.add(New API_Settings__c(Name = 'YouTube Endpoint',value__c='https://www.googleapis.com/youtube/v3/'));
        upsert apiSettingsList; 
        
        Youtube_channel__c ytc = new Youtube_channel__c();
        ytc.Channel_Id__c = 'UC8vzBnByif4adVQr7Vij7SQ';
        ytc.Fetch__c = True;
        insert ytc;
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new searchCalloutMock());
        YouTubeBatchClass ytb = New YouTubeBatchClass();
        id jobid = database.executeBatch(ytb,20);
        Test.stopTest();     
        List<YouTube_Video__c> yvList = [Select id, Video_Id__c from YouTube_Video__c where Youtube_channel__c =:ytc.Id];
        system.assertEquals(0, yvList.size());   
    }
    
    global class channelCalloutMock implements HttpCalloutMock{
        global HttpResponse respond(HTTPRequest req){          
            
            httprequest httpReq =new httprequest();
            httpReq.setEndpoint('https://youtube.googleapis.com/youtube/v3/channels?part=snippet%2Cstatistics&id=UC8vzBnByif4adVQr7Vij7SQ&fields=items(snippet(title%2Cdescription%2CpublishedAt)%2Cstatistics)&key=abcd');
            httpReq.setMethod('GET');
            
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);            
            res.setBody('{'+'\"items\":['+'{'+'\"snippet\":{'+'\"title\":\"WatchFujifilm\",'+'\"description\":\"FUJIFILMGraphicSystemsDivision\\nTheGraphicSystemsDivisionofFUJIFILMNorthAmericaCorporationisrecognizedasalongtermpartnerforprintersfocusedondeliveringhighquality,technicallyadvancedprintsolutionsthathelpprintersdevelopcompetitiveadvantageandgrowtheirbusinesses.Thecompany\'sfinancialstabilityandunprecedentedinvestmentinR&Denableittodevelopproprietarytechnologiesforbest-in-classprinting.Theseincludepre-pressandpressroomsolutionsforoffset,wide-formatanddigitalprint,aswellasworkflowsoftwareforprintproductionmanagement.\",'+'\"publishedAt\":\"2011-09-26T20:13:46Z\"'+'},'+'\"statistics\":{'+'\"viewCount\":\"87970\",'+'\"subscriberCount\":\"390\",'+'\"hiddenSubscriberCount\":false,'+'\"videoCount\":\"75\"'+'}'+'}'+']'+'}');
            return res;                                                
        }               
    }    
    static testMethod void channelTest() {
        
        List<API_Settings__c> apiSettingsList = new List<API_Settings__c>();                
        apiSettingsList.add(New API_Settings__c(Name = 'YouTube API Key',value__c='AIzaSyC_TyKcaLcY99jIu4kLPJd4rwg1MrtNZ6Q'));
        apiSettingsList.add(New API_Settings__c(Name = 'YouTube Endpoint',value__c='https://www.googleapis.com/youtube/v3/'));
        upsert apiSettingsList; 
        
        Youtube_channel__c ytc = new Youtube_channel__c();
        ytc.Channel_Id__c = 'UC8vzBnByif4adVQr7Vij7SQ';
        ytc.Fetch__c = True;
        insert ytc;
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new channelCalloutMock());
        YouTubeBatchClass ytbs = New YouTubeBatchClass();
        id jobid = database.executeBatch(ytbs,20);
        Test.stopTest();     
        List<YouTube_Video__c> yvList = [Select id, Video_Id__c from YouTube_Video__c where Youtube_channel__c =:ytc.Id];
        system.assertEquals(3, yvList.size());   
    }
    
    global class videosCalloutMock implements HttpCalloutMock{
        global HttpResponse respond(HTTPRequest req){          
            
            httprequest httpReq =new httprequest();
            httpReq.setEndpoint('https://youtube.googleapis.com/youtube/v3/videos?part=snippet%2Cstatistics&id=THb9WBNGi58%2C4KLyiEH7JCI%2CySb7PyCF3QY%2CCbuJW%2CFVZFoWMwg6I&fields=items&key=abcd');
            httpReq.setMethod('GET');
            
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);            
            res.setBody('{'+'\"items\":['+'{'+'\"kind\":\"youtube#video\",'+'\"etag\":\"0K2xEq6_YLp4oE9CtzaynRKjE8U\",'+'\"id\":\"THb9WBNGi58\",'+'\"snippet\":{'+'\"publishedAt\":\"2019-07-24T21:36:13Z\",'+'\"channelId\":\"UC8vzBnByif4adVQr7Vij7SQ\",'
                        +'\"title\":\"JPress750S|Overview\",'+'\"description\":\"Thecurrentstateofplayintheprintworldshowsthatshortrunsareontheup.Findinganimblerandmoreefficientwaytokeepupwithcustomers’demandshasdrivenbusinessestoseekanalternativetooffset.Thisiswhereforward-thinkingprinterscanprepareforthefutureandpositionbusinessesattheforefront.Inkjetistheperfecttechnologytoaddressthesechangingmarketconditions,andtheJPress750Sis,withoutdoubt,thefrontrunner.\\n\\nTheJPressserieshasbeensettingthebenchmarkforinkjetqualityandperformancesinceitslaunchfouryearsago.\\n\\nNow,withahigherproductivityof3,600sheetsperhour,andevenbetterup-timeaddedtobreathtakingquality,thenew,third-generationJetPress750Sissettoprovideanevenmorecompellingsolutionforprinterslookingtoupgradetheiroffsetproduction.\",'
                        +'\"thumbnails\":{'+'\"default\":{'+'\"url\":\"https://i.ytimg.com/vi/THb9WBNGi58/default.jpg\",'+'\"width\":120,'+'\"height\":90'+'},'+'\"medium\":{'+'\"url\":\"https://i.ytimg.com/vi/THb9WBNGi58/mqdefault.jpg\",'+'\"width\":320,'+'\"height\":180'+'},'+'\"high\":{'+'\"url\":\"https://i.ytimg.com/vi/THb9WBNGi58/hqdefault.jpg\",'+'\"width\":480,'+'\"height\":360'+'},'+'\"standard\":{'+'\"url\":\"https://i.ytimg.com/vi/THb9WBNGi58/sddefault.jpg\",'+'\"width\":640,'+'\"height\":480'+'},'
                        +'\"maxres\":{'+'\"url\":\"https://i.ytimg.com/vi/THb9WBNGi58/maxresdefault.jpg\",'+'\"width\":1280,'+'\"height\":720'+'}'+'},'+'\"channelTitle\":\"WatchFujifilm\",'+'\"tags\":['+'\"digitalprinting\",'+'\"inkjet\",'+'\"jpress750s\",'+'\"jetpress\",'+'\"commercialprinting\",'+'\"sheetfedprinting\",'+'\"packagingprinting\",'+'\"printproduction\",'+'\"fujifilmprinting\"'+'],'+'\"categoryId\":\"28\",'+'\"liveBroadcastContent\":\"none\",'+'\"localized\":{'
                        +'\"title\":\"JPress750S|Overview\",'+'\"description\":\"Thecurrentstateofplayintheprintworldshowsthatshortrunsareontheup.Findinganimblerandmoreefficientwaytokeepupwithcustomers’demandshasdrivenbusinessestoseekanalternativetooffset.Thisiswhereforward-thinkingprinterscanprepareforthefutureandpositionbusinessesattheforefront.Inkjetistheperfecttechnologytoaddressthesechangingmarketconditions,andtheJPress750Sis,withoutdoubt,thefrontrunner.\\n\\nTheJPressserieshasbeensettingthebenchmarkforinkjetqualityandperformancesinceitslaunchfouryearsago.\\n\\nNow,withahigherproductivityof3,600sheetsperhour,andevenbetterup-timeaddedtobreathtakingquality,thenew,third-generationJetPress750Sissettoprovideanevenmorecompellingsolutionforprinterslookingtoupgradetheiroffsetproduction.\"'+'},'
                        +'\"defaultAudioLanguage\":\"en\"'+'},'+'\"statistics\":{'+'\"viewCount\":\"8098\",'+'\"likeCount\":\"41\",'+'\"favoriteCount\":\"0\",'+'\"commentCount\":\"1\"'+'}'+'},'+'{'+'\"kind\":\"youtube#video\",'+'\"etag\":\"G74fRYf1wzpVFcFTb0AIelHZu1Y\",'+'\"id\":\"4KLyiEH7JCI\",'+'\"snippet\":{'+'\"publishedAt\":\"2020-04-14T16:06:23Z\",'+'\"channelId\":\"UC8vzBnByif4adVQr7Vij7SQ\",'
                        +'\"title\":\"JPress750S|OwnerPerspectiveswithClassicColor\",'+'\"description\":\"ClassicColor,aChicagoareabasedPSP,wasanearlyadopteroftheJPress720S,andexperiencedmuchsuccessovertheyears.TheirthirdgenerationJPress750Shasaddedevenmoresuccesstotheiroperationswith95%uptime,whattheydefinedas“unsurpassedquality”,solidconsistencyandimpressiveROIaccordingtoJeffHernandez,VPatClassicColor.\\n\\nClassicColorisamasteroftheircraftandconstantlyworkstoexpandtheircapabilitiestoexceedtheirclients’highestexpectations.ClassicColorworkswithFortune500s,includingautomotiveandhigh-endfashion,aswellasB2Bs,boutiquebusinesses,andalargevolumeofcreativeagencies.\\n\\nWhenlookingforanewdigitalpress,JeffHernandez,VP,Classic,evaluatednearlyeverythingcurrentlyonthemarket.HernandeztalksofhowClassicarrangeda‘shootout’andhadtwooftheirkeyclientsevaluatetheoutput,side-by-side,priortoinvestinginnewtechnology.JPresswastheclearwinner\\n\\nFujifilmGraphicSystemsisproudofthelongpartnershipwithClassicColor.TolearnmoreaboutClassicColor,visithttps://www.classic-color.com/\\n\\nVisithttps://www.fujifilminkjet.com/jpress750s/formoreinformationontheJPress750S,highqualityproductioninkjetpress.\\n\\nIfyouhavequestionsorwanttoseeJPress750Sprintsamples,contactaFujifilmrepresentativetoday.https://www.fujifilminkjet.com/contact/\",'
                        +'\"thumbnails\":{'+'\"default\":{'+'\"url\":\"https://i.ytimg.com/vi/4KLyiEH7JCI/default.jpg\",'+'\"width\":120,'+'\"height\":90'+'},'+'\"medium\":{'+'\"url\":\"https://i.ytimg.com/vi/4KLyiEH7JCI/mqdefault.jpg\",'+'\"width\":320,'+'\"height\":180'+'},'+'\"high\":{'+'\"url\":\"https://i.ytimg.com/vi/4KLyiEH7JCI/hqdefault.jpg\",'+'\"width\":480,'+'\"height\":360'+'},'+'\"standard\":{'+'\"url\":\"https://i.ytimg.com/vi/4KLyiEH7JCI/sddefault.jpg\",'+'\"width\":640,'+'\"height\":480'+'},'+'\"maxres\":{'+'\"url\":\"https://i.ytimg.com/vi/4KLyiEH7JCI/maxresdefault.jpg\",'+'\"width\":1280,'+'\"height\":720'+'}'+'},'+'\"channelTitle\":\"WatchFujifilm\",'+'\"categoryId\":\"28\",'+'\"liveBroadcastContent\":\"none\",'+'\"localized\":{'+'\"title\":\"JPress750S|OwnerPerspectiveswithClassicColor\",'
                        +'\"description\":\"ClassicColor,aChicagoareabasedPSP,wasanearlyadopteroftheJPress720S,andexperiencedmuchsuccessovertheyears.TheirthirdgenerationJPress750Shasaddedevenmoresuccesstotheiroperationswith95%uptime,whattheydefinedas“unsurpassedquality”,solidconsistencyandimpressiveROIaccordingtoJeffHernandez,VPatClassicColor.\\n\\nClassicColorisamasteroftheircraftandconstantlyworkstoexpandtheircapabilitiestoexceedtheirclients’highestexpectations.ClassicColorworkswithFortune500s,includingautomotiveandhigh-endfashion,aswellasB2Bs,boutiquebusinesses,andalargevolumeofcreativeagencies.\\n\\nWhenlookingforanewdigitalpress,JeffHernandez,VP,Classic,evaluatednearlyeverythingcurrentlyonthemarket.HernandeztalksofhowClassicarrangeda‘shootout’andhadtwooftheirkeyclientsevaluatetheoutput,side-by-side,priortoinvestinginnewtechnology.JPresswastheclearwinner\\n\\nFujifilmGraphicSystemsisproudofthelongpartnershipwithClassicColor.TolearnmoreaboutClassicColor,visithttps://www.classic-color.com/\\n\\nVisithttps://www.fujifilminkjet.com/jpress750s/formoreinformationontheJPress750S,highqualityproductioninkjetpress.\\n\\nIfyouhavequestionsorwanttoseeJPress750Sprintsamples,contactaFujifilmrepresentativetoday.https://www.fujifilminkjet.com/contact/\"'+'}'+'},'+'\"statistics\":{'+'\"viewCount\":\"3627\",'+'\"likeCount\":\"24\",'
                        +'\"favoriteCount\":\"0\",'+'\"commentCount\":\"1\"'+'}'+'},'+'{'+'\"kind\":\"youtube#video\",'+'\"etag\":\"4VNiPkIMzzZON7SfFndlRwB6KKc\",'+'\"id\":\"ySb7PyCF3QY\",'+'\"snippet\":{'+'\"publishedAt\":\"2020-01-31T19:34:36Z\",'+'\"channelId\":\"UC8vzBnByif4adVQr7Vij7SQ\",'+'\"title\":\"DirectEdgeMediaLargeFormatSuccesswithRetailBrands|OwnerPerspectives\",'+'\"description\":\"DirectEdgeMediaopenedtheirdoorsin2001withasmallroll-to-rollphotoprinter,producingphotoalbums.Thecompanyhasreadilyevolvedintoanationalleadingfull-serviceprintingcompanywithofferingsthatincludelargeformat,digitalsheetfed,offset,bindery,directmail,fulfillmentandsupplychainsolutionsforwell-knownglobalclientswithinretail,bankinginstitutions,beveragecompaniesandrestaurantindustries.\\n\\nWorkingwithhighlyvisiblebrandsmeansproducingcontinuouslyinnovativecreativedisplayswhilealsoexecutingatahighlevelfromoperationsandprintquality.DirectEdgeMediaiscommittedtoinvestingintechnologytostayaheadofthecurve.WithmorethansixproductionpressesfromFujifilmincludingtheOnsetXplatformandJPressproductioninkjetpress,DirectEdgeMediahasbeenaFujifilmshopformorethan15years.\\n\\nTheabilitytopartnernotonlyontechnology,butalsoeducateDirectEdgeMediaaboutcreativesolutions,likelenticularprinting,showcasestheinvaluablesupportthatFujifilmGraphicSystemshastooffer.FujifilmKnowsColor!\\n\\nWanttolearnanewprinttechnique,askushow\\nhttps://www.fujifilminkjet.com/contact/\",'
                        +'\"thumbnails\":{'+'\"default\":{'+'\"url\":\"https://i.ytimg.com/vi/ySb7PyCF3QY/default.jpg\",'+'\"width\":120,'+'\"height\":90'+'},'+'\"medium\":{'+'\"url\":\"https://i.ytimg.com/vi/ySb7PyCF3QY/mqdefault.jpg\",'+'\"width\":320,'+'\"height\":180'+'},'+'\"high\":{'+'\"url\":\"https://i.ytimg.com/vi/ySb7PyCF3QY/hqdefault.jpg\",'+'\"width\":480,'+'\"height\":360'+'},'+'\"standard\":{'+'\"url\":\"https://i.ytimg.com/vi/ySb7PyCF3QY/sddefault.jpg\",'+'\"width\":640,'+'\"height\":480'+'}'+'},'+'\"channelTitle\":\"WatchFujifilm\",'+'\"tags\":['+'\"printing\",'+'\"directedgemedia\",'+'\"retailprinting\",'+'\"popsignage\",'+'\"californiaprintingcompany\",'+'\"lenticularprinting\",'+'\"vansvisualcommunication\",'+'\"vansretaildisplays\"'+'],'+'\"categoryId\":\"28\",'+'\"liveBroadcastContent\":\"none\",'+'\"localized\":{'+'\"title\":\"DirectEdgeMediaLargeFormatSuccesswithRetailBrands|OwnerPerspectives\",'
                        +'\"description\":\"DirectEdgeMediaopenedtheirdoorsin2001withasmallroll-to-rollphotoprinter,producingphotoalbums.Thecompanyhasreadilyevolvedintoanationalleadingfull-serviceprintingcompanywithofferingsthatincludelargeformat,digitalsheetfed,offset,bindery,directmail,fulfillmentandsupplychainsolutionsforwell-knownglobalclientswithinretail,bankinginstitutions,beveragecompaniesandrestaurantindustries.\\n\\nWorkingwithhighlyvisiblebrandsmeansproducingcontinuouslyinnovativecreativedisplayswhilealsoexecutingatahighlevelfromoperationsandprintquality.DirectEdgeMediaiscommittedtoinvestingintechnologytostayaheadofthecurve.WithmorethansixproductionpressesfromFujifilmincludingtheOnsetXplatformandJPressproductioninkjetpress,DirectEdgeMediahasbeenaFujifilmshopformorethan15years.\\n\\nTheabilitytopartnernotonlyontechnology,butalsoeducateDirectEdgeMediaaboutcreativesolutions,likelenticularprinting,showcasestheinvaluablesupportthatFujifilmGraphicSystemshastooffer.FujifilmKnowsColor!\\n\\nWanttolearnanewprinttechnique,askushow\\nhttps://www.fujifilminkjet.com/contact/\"'+'},'+'\"defaultAudioLanguage\":\"en\"'+'},'+'\"statistics\":{'+'\"viewCount\":\"577\",'+'\"likeCount\":\"10\",'+'\"favoriteCount\":\"0\",'+'\"commentCount\":\"0\"'+'}'+'},'+'{'+'\"kind\":\"youtube#video\",'+'\"etag\":\"YwUJ5jRZAsKgFmsoG5YzVKaJXI0\",'
                        +'\"id\":\"FVZFoWMwg6I\",'+'\"snippet\":{'+'\"publishedAt\":\"2013-09-23T16:12:48Z\",'+'\"channelId\":\"UC8vzBnByif4adVQr7Vij7SQ\",'+'\"title\":\"OnsetQ40iNGSPrinting\",'+'\"description\":\"\",'+'\"thumbnails\":{'+'\"default\":{'+'\"url\":\"https://i.ytimg.com/vi/FVZFoWMwg6I/default.jpg\",'+'\"width\":120,'+'\"height\":90'+'},'+'\"medium\":{'+'\"url\":\"https://i.ytimg.com/vi/FVZFoWMwg6I/mqdefault.jpg\",'+'\"width\":320,'+'\"height\":180'+'},'+'\"high\":{'+'\"url\":\"https://i.ytimg.com/vi/FVZFoWMwg6I/hqdefault.jpg\",'+'\"width\":480,'+'\"height\":360'+'},'+'\"standard\":{'+'\"url\":\"https://i.ytimg.com/vi/FVZFoWMwg6I/sddefault.jpg\",'+'\"width\":640,'+'\"height\":480'+'},'+'\"maxres\":{'+'\"url\":\"https://i.ytimg.com/vi/FVZFoWMwg6I/maxresdefault.jpg\",'+'\"width\":1280,'+'\"height\":720'+'}'+'},'+'\"channelTitle\":\"WatchFujifilm\",'+'\"categoryId\":\"28\",'+'\"liveBroadcastContent\":\"none\",'+'\"localized\":{'+'\"title\":\"OnsetQ40iNGSPrinting\",'+'\"description\":\"\"'+'}'+'},'+'\"statistics\":{'+'\"viewCount\":\"150\",'+'\"likeCount\":\"1\",'+'\"favoriteCount\":\"0\",'+'\"commentCount\":\"0\"'+'}'+'}'+']'+'}');
            return res;                                                
        }               
    }    
    static testMethod void videoTest() {
        
        List<API_Settings__c> apiSettingsList = new List<API_Settings__c>();                
        apiSettingsList.add(New API_Settings__c(Name = 'YouTube API Key',value__c='AIzaSyC_TyKcaLcY99jIu4kLPJd4rwg1MrtNZ6Q'));
        apiSettingsList.add(New API_Settings__c(Name = 'YouTube Endpoint',value__c='https://www.googleapis.com/youtube/v3/'));
        upsert apiSettingsList; 
        
        Youtube_channel__c ytc = new Youtube_channel__c();
        ytc.Channel_Id__c = 'UC8vzBnByif4adVQr7Vij7SQ';
        ytc.Fetch__c = True;
        insert ytc;
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new videosCalloutMock());
        YouTubeBatchClass ytbv = New YouTubeBatchClass();
        id jobid = database.executeBatch(ytbv,20);
        Test.stopTest();     
        List<YouTube_Video__c> yvList = [Select id, Video_Id__c from YouTube_Video__c where Youtube_channel__c =:ytc.Id];
        system.assertEquals(3, yvList.size());   
    }
}