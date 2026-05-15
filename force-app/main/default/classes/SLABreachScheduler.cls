public class SLABreachScheduler implements schedulable {
    public void execute(SchedulableContext sc){
        SLABreachMonitoringBatch batch = new SLABreachMonitoringBatch();
        Database.executeBatch(batch, 200);
    }
}