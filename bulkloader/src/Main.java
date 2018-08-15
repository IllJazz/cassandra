public class Main {
    @Test
    public void testThroughput() throws Exception {
        Cluster cluster = Cluster.builder()
                .addContactPoint("localhost")
                .withProtocolVersion(ProtocolVersion.V2)
                .withPort(9042)
                .build();
        Session session = cluster.connect();
        session.execute("CREATE KEYSPACE IF NOT EXISTS test" +
                " WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'}");
        session.execute("USE test");
        session.execute("CREATE TABLE IF NOT EXISTS parent_children (" +
                " parentId uuid," +
                " childId uuid," +
                " PRIMARY KEY (parentId, childId))");
        UUID parent = UUID.randomUUID();
        long beforeInsert = System.currentTimeMillis();
        List<ResultSetFuture> futures = new ArrayList<>();
        int n = 1000000;
        for (int i = 0; i < n; i++) {
            UUID child = UUID.randomUUID();
            futures.add(session.executeAsync("INSERT INTO parent_children (parentId, childId) VALUES (?, ?)", parent, child));
            if (i % 10000 == 0) {
                System.out.println("Inserted " + i + " of " + n + " items (" + (100 * i / n) + "%)");
            }
        }
        //to be honest with ourselves let's wait for all to finish and succeed
        List<ResultSet> succeeded = Futures.successfulAsList(futures).get();
        Assert.assertEquals(n, succeeded.size());
        long endInsert = System.currentTimeMillis();
        System.out.println("Time to insert: " + (endInsert-beforeInsert) + "ms; " + 1000 * n/(endInsert-beforeInsert) +  " per second");
        cluster.close();
    }
}
