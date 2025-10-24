public class BoardGameServiceResults{
    public List<Board_Games__c> newBoardGames = new List<Board_Games__c>();
    public List<Board_Games__c> updatedBoardGames = new List<Board_Games__c>();
    public List<BG_Library_Entry__c> newBGLEs = new List<BG_Library_Entry__c>();
    public List<BG_Library_Entry__c> updatedBGLEs = new List<BG_Library_Entry__c>();
    public List<BG_Library_Entry__c> removedBGLEs = new List<BG_Library_Entry__c>();
    public String sourceName;
    public String sourceType;
    public ID eventId;
    public Set<String> unprocessedIds;
    public Boolean errorOccured = false;
    public List<String> errorMessages = new List<String>();
    public Map<Id, Map<String, Map<Object, Object>>> boardGameChanges;
    public Map<Id, Map<String, Map<Object, Object>>> bgleChanges;
}
