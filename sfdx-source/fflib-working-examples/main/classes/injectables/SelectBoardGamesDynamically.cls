public inherited sharing class SelectBoardGamesDynamically extends AbstractSelectorMethodInjectable implements ISelectorMethodInjectable {
    
    private BoardGameSelector selector = (BoardGameSelector) BoardGameSelector.newInstance();

    public List<SObject> selectQuery(){
        SelectBoardGamesDynamically.Parameters params = (SelectBoardGamesDynamically.Parameters) getParameters();
    
        if(params.getWithSharing()){
            return new WithSharing().selectQuery(this);
        }

        return new WithoutSharing().selectQuery(this);
    }

    public List<Board_Game__c> executeQuery() {
        SelectBoardGamesDynamically.Parameters params = (SelectBoardGamesDynamically.Parameters) getParameters();

        Set<Id> ids = params.getIds();
        Set<String> fieldSet = params.getFieldSet();
        String orderByField = params.getOrderByField();
        Integer orderByDirection = params.getOrderByDirection();

        fflib_QueryFactory queryFactory = newQueryFactory();

        String queryFilter = '';
        // Build Query Filter from Parameters
        if(!ids.isEmpty()){
            queryFilter += Board_Game__c.Id + ' IN: ids';
        }

        if(!fieldSet.isEmpty()){
            queryFactory.selectFields(fieldSet);
        } 

        fflib_QueryFactory.SortOrder sortOrder = orderByDirection == 1 
            ? fflib_QueryFactory.SortOrder.ASCENDING
            : fflib_QueryFactory.SortOrder.DESCENDING;

        return Database.query(
            queryFactory
                .setCondition(queryFilter)
                .setOrdering(orderByField, sortOrder)
                .toSOQL()
        );

    }

    public class Parameters implements ISelectorMethodParameterable {
        
        // List of Query Parameters
        private Set<Id> ids = new Set<Id>();

        // List of Query Settings
        private Set<String> fieldSet = new Set<String>();
        private Integer orderByDirection = 1; // ASC = 1, DESC = 0
        private String orderByField = 'Name'; // Default Order By Field for Query
        private Boolean withSharing = true;

        //Getters
        public Set<Id> getIds() {
            return this.ids;
        }

        public Set<String> getFieldSet() {
            return this.fieldSet;
        }

        public Integer getOrderByDirection() {
            return this.orderByDirection;
        }

        public String getOrderByField() {
            return this.orderByField;
        }

        public Boolean getWithSharing() {
            return this.withSharing;
        }

        //Setters
        public Parameters id(Id id) {
            this.ids(new Set<ID>{id});
            return this;
        }
        
        public Parameters ids(Set<Id> ids) {
            this.ids.addAll(ids);
            return this;
        }

        public Parameters fieldSet(Set<String> fieldSet) {
            this.fieldSet.addAll(fieldSet);
            return this;
        }

        public Parameters orderByDirection(Integer orderByDirection) {
            this.orderByDirection = orderByDirection;
            return this;
        }

        public Parameters orderByField(String orderByField) {
            this.orderByField = orderByField;
            return this;
        }

        public Parameters withoutSharing(){
            this.withSharing = false;
            return this;
        }

        public Boolean equals(Object obj){
            if(!(obj instanceof Parameters)){
                return false;
            }

            Parameters params = (Parameters) obj;
            return (
                // List of Parameter variables
                this.ids == params.ids &&

                this.fieldSet == params.fieldSet &&
                this.orderByDirection == params.orderByDirection &&
                this.orderByField == params.orderByField &&
                this.withSharing == params.withSharing
            );
        }
    }

    private with sharing class WithSharing{
        public List<Board_Game__c> selectQuery(SelectBoardGamesDynamically selector){
            return selector.executeQuery();
        }
    }

    private without sharing class WithoutSharing{
        public List<Board_Game__c> selectQuery(SelectBoardGamesDynamically selector){
            return selector.executeQuery();
        }
    }
    
}