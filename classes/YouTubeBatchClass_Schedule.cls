global class YouTubeBatchClass_Schedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        YouTubeBatchClass ytb = New YouTubeBatchClass();
        database.executeBatch(ytb,20);
    }
}