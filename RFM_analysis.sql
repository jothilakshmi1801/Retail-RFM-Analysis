select*from sales_data;
select*from sales_data where customerid is null;
CREATE TABLE sales_clean AS
SELECT *
FROM sales_data
WHERE CustomerID IS NOT NULL;
DELETE FROM sales_clean
WHERE Quantity <= 0 OR UnitPrice <1;
ALTER TABLE sales_clean
ADD TotalAmount NUMBER;
UPDATE sales_clean
SET TotalAmount = Quantity * UnitPrice;
select*from sales_data;
SELECT COUNT(*) FROM sales_clean;
SELECT MAX(InvoiceDate) FROM sales_clean;
CREATE TABLE rfm_base AS
SELECT 
    CustomerID,

    -- Recency (days since last purchase)
    (SELECT MAX(InvoiceDate) FROM sales_clean) - MAX(InvoiceDate) AS Recency,

    -- Frequency (number of invoices)
    COUNT(DISTINCT InvoiceNo) AS Frequency,

    -- Monetary (total spending)
    SUM(TotalAmount) AS Monetary

FROM sales_clean
GROUP BY CustomerID;
SELECT * FROM rfm_base;
CREATE TABLE rfm_scores AS
SELECT 
    CustomerID,
    Recency,
    Frequency,
    Monetary,

    NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
    NTILE(5) OVER (ORDER BY Frequency) AS F_Score,
    NTILE(5) OVER (ORDER BY Monetary) AS M_Score

FROM rfm_base;
select*from rfm_scores;
create table rfm_final as
SELECT 
    rs.*,
    CASE 
        WHEN rs.R_Score >= 4 AND rs.F_Score >= 4 AND rs.M_Score >= 4 THEN 'Best Customers'
        WHEN rs.R_Score >= 3 AND rs.F_Score >= 3 THEN 'Loyal Customers'
        WHEN rs.R_Score <= 2 THEN 'At Risk'
        ELSE 'Others'
    END AS Segment
FROM rfm_scores rs;
SELECT * FROM rfm_final;
SELECT table_name 
FROM user_tables
WHERE table_name = 'RFM_FINAL';