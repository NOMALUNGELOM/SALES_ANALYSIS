SELECT *
FROM "SALES"."CASESTUDY"."SALES_ANALYSIS"
LIMIT 10;

-- SHOW ALL DATA WITH CALCULATED METRICS
SELECT
    Date,
    Sales,
    Cost_Of_Sales,
    Quantity_Sold,

    -- 1. DAILY PRICE PER UNIT
    (Sales / NULLIF(Quantity_Sold,0)) AS Daily_Unit_Price,

    -- 2. AVERAGE UNIT PRICE ACROSS ENTIRE DATA
    (SELECT AVG(Sales / NULLIF(Quantity_Sold,0)) FROM SALES_ANALYSIS) AS Avg_Unit_Price,

    -- 3. DAILY % GROSS PROFIT
    ((Sales - Cost_Of_Sales) / NULLIF(Sales,0)) * 100 AS Daily_Gross_Profit_Percent,

    -- 4. DAILY GROSS PROFIT PER UNIT
    ((Sales - Cost_Of_Sales) / NULLIF(Quantity_Sold,0)) AS Daily_Gross_Profit_Per_Unit,

    -- 5. DAILY % GROSS PROFIT PER UNIT
    (
        ((Sales - Cost_Of_Sales) / NULLIF(Quantity_Sold,0))
        /
        (Sales / NULLIF(Quantity_Sold,0))
    ) * 100 AS Daily_Gross_Profit_Per_Unit_Percent,

    -- 6. PROMO FLAG
    CASE 
        WHEN (Sales / NULLIF(Quantity_Sold,0)) <
             (SELECT AVG(Sales / NULLIF(Quantity_Sold,0)) FROM SALES_ANALYSIS)
        THEN 'PROMOTION'
        ELSE 'NORMAL PRICE'
    END AS Promo_Flag,

    -- 7. DEMAND FLAG
    CASE
        WHEN Quantity_Sold > (
            SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Quantity_Sold)
            FROM SALES_ANALYSIS
        )
        THEN 'HIGH DEMAND DAY'
        ELSE 'NORMAL DEMAND'
    END AS Demand_Flag,

    -- 8. GROSS PROFIT VALUE
    (Sales - Cost_Of_Sales) AS Gross_Profit_Value

FROM SALES_ANALYSIS
ORDER BY Date;
