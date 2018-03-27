PRINT 'Info: Creating the ''microsoft.vw_tables_with_skew'' view';
GO

CREATE VIEW microsoft.vw_tables_with_skew AS
SELECT
    *
FROM
    microsoft.vw_table_sizes
WHERE two_part_name IN
(
    SELECT 
        two_part_name
    FROM
        microsoft.vw_table_sizes
    WHERE
        row_count > 0
    GROUP BY
        two_part_name
    HAVING MIN(row_count * 1.000) / MAX(row_count * 1.000) > .10
)
GO