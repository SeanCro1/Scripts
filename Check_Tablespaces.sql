SELECT tablespace_name,
       size_gb,
       free_gb,
       max_size_gb,
       max_free_gb,
       TRUNC((max_free_gb/max_size_gb) * 100) AS free_pct,
       RPAD(' '|| RPAD('X',ROUND((max_size_gb-max_free_gb)/max_size_gb*10,0), 'X'),11,'-') AS used_pct
FROM   (
        SELECT a.tablespace_name,
               b.size_gb,
               a.free_gb,
               b.max_size_gb,
               a.free_gb + (b.max_size_gb - b.size_gb) AS max_free_gb
        FROM   (SELECT tablespace_name,
                       TRUNC(SUM(bytes)/1024/1024/1024) AS free_gb
                FROM   dba_free_space
                GROUP BY tablespace_name) a,
               (SELECT tablespace_name,
                       TRUNC(SUM(bytes)/1024/1024/1024) AS size_gb,
                       TRUNC(SUM(GREATEST(bytes,maxbytes))/1024/1024/1024) AS max_size_gb
                FROM   dba_data_files
                GROUP BY tablespace_name) b
        WHERE  a.tablespace_name = b.tablespace_name
       )
ORDER BY tablespace_name;
