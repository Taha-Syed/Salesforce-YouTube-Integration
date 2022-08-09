/* Description						: When user creates a channel record with YouTube channelId, fetch channel
*									  details, channel stats, video detals and video stats on schedule.									  
* Created Date						: 08/03/2022
* Version							: 1.0
* @author							: Taha Syed
* Documentation 					: YouTube Data API v3 - https://developers.google.com/youtube/v3/docs/
* Resource Type-Quota cost/call)	: (Search - 100) (Channels - 1) (Videos - 1) 
* Quota Limit						: 10,000/day
* Last Modified By					: Taha Syed
* Last Modified Date				: 08/08/2022
*/

global class YouTubeBatchClass implements Database.Batchable<sObject>,
Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<YouTube_Video__c> videosList2Create = New List<YouTube_Video__c>(); //this will hold video records that need to be inserted    
        List<YouTube_Channel__c> ChannelList2Update = New List<YouTube_Channel__c>(); //final list to update channel stats
        List<YouTube_Channel_Stats__c> ChannelStatsList2Update = New List<YouTube_Channel_Stats__c>(); //final list to insert YouTube Channel Stats
        
        Map<String,Id> channelIdRecordIdMap = New  Map<String,Id>();
        List<String> ChannelIds = New List<String>();
        List<Id> ChannelRecordIds = New List<Id>();
        for (YouTube_Channel__c y:[Select id, Channel_Id__c from YouTube_Channel__c Where Channel_Id__c != Null AND Fetch__c = True] ) {
            ChannelIds.add(y.Channel_Id__c);
            ChannelRecordIds.add(y.id);
            channelIdRecordIdMap.put(y.Channel_Id__c,y.id);
        } //get all curr channel ids
        
        Map<String,String> videoIdChannelIdMap = New Map<String,String>(); //video Ids and channel id map. videoIds collected from http response
        List<YouTube_Video__c> videoList = [Select Video_Id__c,Id from YouTube_Video__c where YouTube_Video__c.YouTube_Channel__c IN :ChannelRecordIds]; //existing videos list
        List<String> videoIdList = New List<String>(); //existing video Ids list
        for (YouTube_Video__c ytl:videoList) {
            videoIdList.add(ytl.Video_Id__c);
        }
        
        String endpt			= API_Settings__c.getInstance( 'YouTube Endpoint' ).Value__c;
        String apikey			= API_Settings__c.getInstance( 'YouTube API Key' ).Value__c;           
        String endptType		= 'search';
        String endptpart		= 'snippet';
        String endptMaxResults	= '100';
        String endptfields		= 'pageInfo%2CnextPageToken%2Citems(id(videoId))';
        String endptPageToken	= '';
        
        for (string ytc:ChannelIds) {
            do {
                String finalEndpt	 = endpt + endptType + '?part=' +endptpart +'&channelId=' +ytc + '&maxResults=' + endptMaxResults + '&pageToken=' +endptPageToken + '&fields=' +endptfields + '&key=' + apikey;
                HttpRequest httpReq  = new HttpRequest();
                Http http            = new Http();
                HttpResponse httpRes = new HttPResponse();        
                httpReq.setMethod( 'GET' );
                httpReq.setEndpoint( finalEndpt );        
                httpRes = http.send( httpReq );
                system.debug('Response : ' +httpRes.getStatusCode() + ' ' +httpRes.getStatus());
                system.debug('EndPoint ' +finalEndpt);
                if (httpRes.getStatusCode() == 200) {                    
                    searchJSON sj = (searchJSON)JSON.deserialize(httpRes.getBody(),searchJSON.class);                    
                    for (integer i=0;i<sj.items.size();i++) {
                        if(sj.items[i].id != null){
                            String var = sj.items[i].id.videoId;
                            If (!String.isBlank(var) && !videoIdChannelIdMap.keyset().contains(var) ){
                                videoIdChannelIdMap.put(var,ytc);                    
                            } 
                        }
                    }
                    
                    //Check more results using nextPageToken. If nextPageToken is not blank,
                    //fetch the next page results, parse them and add to videoIds list using do while loop
                    if(!String.isBlank(sj.nextPageToken)) {
                        endptPageToken = sj.nextPageToken;
                        sj.nextPageToken = '';
                    } else {
                        endptPageToken = '';
                    }
                } 
                else {
                    system.debug('Response : ' +httpRes.getStatusCode() + ' ' +httpRes.getStatus());
                }
            } while (!String.isBlank(endptPageToken));                       
            
            
            //Get channel statistics via another api call
          //  endpt			= API_Settings__c.getInstance( 'YouTube Endpoint' ).Value__c;
          //  apikey			= API_Settings__c.getInstance( 'YouTube API Key' ).Value__c;           
            endptType		= 'channels';
            endptpart		= 'snippet%2Cstatistics';
          //  endptMaxResults	= '100';
            endptfields		= 'items(snippet(title%2Cdescription%2CpublishedAt)%2Cstatistics)';
         //   endptPageToken  = '';
            String finalEndpt		= endpt + endptType + '?part=' +endptpart +'&id=' +ytc +  '&fields=' +endptfields + '&key=' + apikey;
            
            HttpRequest httpReq  = new HttpRequest();
            Http http            = new Http();
            HttpResponse httpRes = new HttPResponse();        
            httpReq.setMethod( 'GET' );
            httpReq.setEndpoint( finalEndpt );        
            httpRes = http.send( httpReq );        
            channelJSON cj = (channelJSON)JSON.deserialize(httpRes.getBody(),channelJSON.class);
            String Title = cj.items[0].snippet.title;
            String Description = cj.items[0].snippet.description;
            Double Views = decimal.valueof(cj.items[0].statistics.viewCount);
            Double Videos = decimal.valueof(cj.items[0].statistics.videoCount);
            Double Subscribers = decimal.valueof(cj.items[0].statistics.subscriberCount);
            
            YouTube_Channel__c ytcupdate = new YouTube_Channel__c();
            ytcupdate.id = channelIdRecordIdMap.get(ytc);
            If (!String.isBlank(Title)) {
                ytcupdate.Title__c = Title;                     
            }
            If (!String.isBlank(Description)) {
                ytcupdate.Description__c = Description;                     
            }
            If (!String.isBlank(cj.items[0].snippet.publishedAt)) {
                string pA = cj.items[0].snippet.publishedAt;
                ytcupdate.Published_At__c = Datetime.valueOf(pA.replace('T',' '));
            }
            ChannelList2Update.add(ytcupdate); //channel object to update
            
            YouTube_Channel_Stats__c ytcStats = new YouTube_Channel_Stats__c();
            ytcStats.YouTube_Channel__c = channelIdRecordIdMap.get(ytc);
            if(Views != null && Views >0) {
                ytcStats.Views__c = Views;
            }
            if(Videos != null && Videos >0) {
                ytcStats.Videos__c = Videos;
            }
            if(Subscribers != null && Subscribers >0) {
                ytcStats.Subscribers__c = Subscribers;
            }
            ChannelStatsList2Update.add(ytcStats); //channel stats object to update
        }   ////for each channel, get videIds, Channel Info and channel Statistics using the YouTube Data API
        
        for (String str:videoIdChannelIdMap.keyset()){
            If(!videoIdList.contains(str)){
                YouTube_Video__c newVideo = New YouTube_Video__c();
                newVideo.Video_Id__c = str;
                newVideo.YouTube_Channel__c = channelIdRecordIdMap.get(videoIdChannelIdMap.get(str));      
                videosList2Create.add(newVideo);
            }
        }  //compare existing and new videos
        
        if (videosList2Create.size()>0 ){
            try{
                database.insert(videosList2Create);
            } catch (exception e) {
                system.debug('The following exception has occured');
            }   
        }         //Insert Videos
        if (ChannelList2Update.size()>0 ){
            try{
                database.update(ChannelList2Update);
            } catch (exception e) {
                system.debug('The following exception has occured');
            }   
        }       //Update Channel Info
        if (ChannelStatsList2Update.size()>0 ){
            try{ 
                database.insert(ChannelStatsList2Update); //insert channel stats
            } catch (exception e){ 
                system.debug('The following exception has occured: ' +e.getMessage());  
            }
        } //Insert Channel Stats
        
        
        String query = 'select id,Video_Id__c from YouTube_Video__c where Video_Id__c != null AND YouTube_Channel__r.Fetch__c = True ORDER BY Name ASC';
        return Database.getQueryLocator(query);
    }    //create videos and update channel info and stats
    
    global void execute(Database.BatchableContext BC, List<YouTube_Video__c> scope){    
        List<String> str = New List<String>();
        String videoId;
        for (YouTube_Video__c y:scope) {
            if(!String.isBlank(y.Video_Id__c)) {
                str.add(y.Video_Id__c);
            }
        }
        videoId = string.join(str, ',');
        
        String endpt			= API_Settings__c.getInstance( 'YouTube Endpoint' ).Value__c;
        String apikey			= API_Settings__c.getInstance( 'YouTube API Key' ).Value__c;           
        String endptType		= 'videos';
        String endptpart		= 'snippet%2Cstatistics';
        String endptMaxResults	= '100';
        String endptfields		= 'items';
        String endptPageToken = '';
        String finalEndpt		= endpt + endptType + '?part=' +endptpart + '&id=' + videoId + '&maxResults='
            + endptMaxResults + '&pageToken=' +endptPageToken + '&fields=' +endptfields + '&key=' + apikey;
        
        HttpRequest httpReq  = new HttpRequest();
        Http http            = new Http();
        HttpResponse httpRes = new HttPResponse();        
        httpReq.setMethod( 'GET' );
        httpReq.setEndpoint( finalEndpt );        
        httpRes = http.send( httpReq );        
        videosJSON vj = (videosJSON)JSON.deserialize(httpRes.getBody(),videosJSON.class);       
        
        List<YouTube_Video_Statistics__c> statsList2Insert = New List<YouTube_Video_Statistics__c>();
        List<YouTube_Video__c> videoList2Update = New List<YouTube_Video__c>();        
        Map<String,Id> videoIdRecordIdMap = New Map<String,Id>();        
        
        for (YouTube_Video__c yvVar:scope) {
            if(!String.isBlank(yvVar.Video_Id__c) && !videoIdRecordIdMap.keyset().contains(yvVar.Video_Id__c)) {
                videoIdRecordIdMap.put(yvVar.Video_Id__c,yvVar.Id);
            }
        }
        
        for (Integer i=0;i<vj.items.size();i++) {            
            {   // Update Video Details
                String Title = vj.items[i].snippet.title;
                String Description =  vj.items[i].snippet.description;
                String ChannelId = vj.items[i].snippet.channelId;
                String ChannelTitle = vj.items[i].snippet.channelTitle;
                String Thumbnail = vj.items[i].snippet.thumbnails.high.url;
                
                YouTube_Video__c ytv = New YouTube_Video__c();                
                ytv.id = videoIdRecordIdMap.get(vj.items[i].id);
                If (!String.isBlank(Title)) {
                    ytv.Title__c = Title;                     
                }
                If (!String.isBlank(Description)) {
                    ytv.description__c = Description;                     
                }                
                If (!String.isBlank(ChannelId)) {
                    ytv.Channel_Id__c = ChannelId;                     
                }
                If (!String.isBlank(ChannelTitle)) {
                    ytv.Channel_Title__c = ChannelTitle;                     
                }
                If (!String.isBlank(Thumbnail)) {
                    ytv.Thumbnail__c = Thumbnail;                     
                }
                If (vj.items[i].snippet.tags != null) {
                    string finalTag = '';
                    for (string tg:vj.items[i].snippet.tags) {
                        finalTag = finalTag + tg + ', ';
                    }
                    If(!String.isBlank(finalTag)) {
                        ytv.Tags__c = finalTag;
                    }
                }
                If (!String.isBlank(vj.items[i].snippet.publishedAt)) {
                    string pA = vj.items[i].snippet.publishedAt;
                    ytv.PublishedAt__c = Datetime.valueOf(pA.replace('T',' '));
                }
                If(ytv.id != null) {
                    videoList2Update.add(ytv);                                        
                }                
            }
            {   //  Insert video Stats                
                YouTube_Video_Statistics__c yvs= new YouTube_Video_Statistics__c();                
                Double Views = decimal.valueof(vj.items[i].statistics.viewCount);
                Double Likes = decimal.valueof(vj.items[i].statistics.likeCount);
                Double Favorites = decimal.valueof(vj.items[i].statistics.favoriteCount);   
                Double Comments = decimal.valueof(vj.items[i].statistics.commentCount);                
                
                yvs.YouTube_Video__c = videoIdRecordIdMap.get(vj.items[i].id);                
                If (Views != null && Views >=0) {
                    yvs.views__c = Views;
                }
                If (Likes != null && Likes >=0) {
                    yvs.Likes__c = Likes; 
                }
                If (Favorites != null && Favorites >=0) {
                    yvs.Favorites__c = Favorites;
                }
                If (Comments != Null && Comments >=0) {
                    yvs.Comments__c = Comments;
                }                
                If(yvs.YouTube_Video__c !=Null) {
                    statsList2Insert.add(yvs);
                }
            }
        }
        
        If (statsList2Insert != Null && !statsList2Insert.isEmpty()) {
            Try{
                database.insert(statsList2Insert);
            } catch (exception e){
                system.debug('The following exception has occured: ' +e.getMessage());    
            }
        }
        If (videoList2Update != Null && !videoList2Update.isEmpty()) {            
            Try { 
                database.update(videoList2Update);
            } catch (exception e){
                system.debug('The following exception has occured: ' +e.getMessage());    
            }
        }
    } //Get video details and video stats in batches
    
    public class searchJSON {
        public search_items[] items{get;set;}
        public search_pageInfo pageInfo{get;set;}
        public String nextPageToken{get;set;}
    }    
    public class search_pageInfo {
        public Integer totalResults{get;set;}
        public Integer resultsPerPage{get;set;}
    }
    public class search_items {
        public search_id id{get;set;}
    }
    public class search_id {
        public String videoId{get;set;}
    }    
    
    public class channelJSON {
        public channel_items[] items{get;set;}        
    }
    public class channel_items {
        public channel_snippet snippet{get;set;}
        public channel_statistics statistics{get;set;}  
    }    
    public class channel_snippet {
        public String title{get;set;}
        public String description{get;set;}
        public String publishedAt{get;set;}
    }    
    public class channel_statistics {
        public String viewCount{get;set;}
        public String subscriberCount{get;set;}
        public String videoCount{get;set;}
    }
    
    public class videosJSON{
        public videos_pageInfo pageInfo{get;set;}
        public list<videos_items> items{get;set;}
    }
    public class videos_PageInfo{
        public Integer totalResults{get;set;}
        public Integer resultsPerPage{get;set;} 
    }
    public class videos_items{
        public String id{get;set;}
        public videos_statistics statistics{get;set;}
        public videos_snippet snippet{get;set;}
    }
    public class videos_statistics{
        public String viewCount{
            get {
                if(viewCount == null){
                    viewCount = '0';
                }
                return viewCount;
            } set;
        }
        public String likeCount{
            get {
                if(likeCount == null){
                    likeCount = '0';
                }
                return favoriteCount;
            } set;
        }
        public String favoriteCount{
            get {
                if(favoriteCount == null){
                    favoriteCount = '0';
                }
                return favoriteCount;
            } set;
        }
        public String commentCount {
            get {
                if(commentCount == null){
                    commentCount = '0';
                }
                return commentCount;
            } set;
        }
    } 
    public class videos_snippet{
        public String title{get;set;}
        public String description{get;set;}
        public String publishedAt{get;set;}
        public String channelId{get;set;}
        public string channelTitle{get;set;}
        public videos_thumbnails thumbnails{get;set;}
        public List<string> tags{get;set;}
    }
    public class videos_thumbnails {        
        public videos_high high{get;set;}
    }
    public class videos_high{
        public string url{get;set;}
    } 
    
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob jb = [Select Id,CompletedDate,ExtendedStatus,JobItemsProcessed,JobType,LastProcessed,LastProcessedOffset,MethodName,NumberOfErrors,Status,TotalJobItems,ApexClassId,CronTriggerId,ParentJobId 
                           From AsyncApexJob
                           Where id=:bc.getJobId()];
        
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        String[] sendingTo = New String[]{'taha.syed@fujifilm.com'};
            msg.setToAddresses(sendingTo);
        
        msg.setSubject('YouTube Batch Update Results');
        
        string htmlBody = '<br/><br/>Completed Date: ' + jb.CompletedDate;
        htmlBody = htmlBody + '<br/>Status: ' + jb.Status;
        htmlBody = htmlBody + '<br/>Total Job Items: ' + jb.TotalJobItems;
        htmlBody = htmlBody + '<br/>Job Items Processed: ' + jb.JobItemsProcessed;
        htmlBody = htmlBody + '<br/>Job Type: ' + jb.JobType;
        htmlBody = htmlBody + '<br/>Number of Errors: ' + jb.NumberOfErrors;
        
        htmlBody = htmlBody + '<br/><br/>Extended Status: ' + jb.ExtendedStatus;
        htmlBody = htmlBody + '<br/>Last Processed: ' + jb.LastProcessed;
        htmlBody = htmlBody + '<br/>Last Processed Offset: ' + jb.LastProcessedOffset;
        htmlBody = htmlBody + '<br/>Method Name: ' + jb.MethodName;
        
        htmlBody = htmlBody + '<br/><br/>Job ID: ' + jb.Id;        
        htmlBody = htmlBody + '<br/><br/>Apex Class Id: ' + jb.ApexClassId;
        htmlBody = htmlBody + '<br/>Cron Trigger Id: ' + jb.CronTriggerId;
        htmlBody = htmlBody + '<br/>Parent Job id: ' + jb.ParentJobId + '<br/><br/>';
        
        msg.setHtmlBody(htmlBody);
        messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});        
        
    }    //send process results to admin via email
}