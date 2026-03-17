public with sharing class ProjectShareService {

    public static void shareProjectsWithUsers(Map<Id, Id> projectToUserMap, String accessLevel) {
        if (projectToUserMap == null || projectToUserMap.isEmpty()) {
            return;
        }

        List<Project__Share> sharesToInsert = new List<Project__Share>();

        for (Id projectId : projectToUserMap.keySet()) {
            Id targetUserId = projectToUserMap.get(projectId);

            Project__Share projShare = new Project__Share();
            projShare.ParentId = projectId;
            projShare.UserOrGroupId = targetUserId;
            projShare.AccessLevel = accessLevel;
            
            projShare.RowCause = Schema.Project__Share.RowCause.Manual;

            sharesToInsert.add(projShare);
        }

        if (!sharesToInsert.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(sharesToInsert, false);
            
        }
    }

}