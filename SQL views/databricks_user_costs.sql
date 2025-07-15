CREATE VIEW IF NOT EXISTS CatalogName.SchemaName.ViewName
COMMENT "This dynamic view calculates the cost of usage per workspace and SKU by summing the usage quantity multiplied by the corresponding pricing, filtered for the current user."
AS
SELECT   
    u.workspace_id, 
    u.sku_name,
    ROUND(SUM(u.usage_quantity * p.pricing.default), 3) AS cost,
    u.usage_date 
FROM   
    system.billing.usage u    
JOIN   
    system.billing.list_prices p    
ON   
    u.sku_name = p.sku_name   
    AND u.cloud = p.cloud   
    AND u.usage_unit = p.usage_unit    
WHERE   
    u.usage_start_time >= p.price_start_time   
    AND u.usage_end_time < COALESCE(p.price_end_time, '2999-12-31')
    AND (u.identity_metadata.run_as = CURRENT_USER() OR u.identity_metadata.created_by = CURRENT_USER())
GROUP BY
    u.workspace_id, u.sku_name, u.usage_date
ORDER BY
    u.usage_date DESC