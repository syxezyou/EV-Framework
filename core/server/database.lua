EV.Database = {}
function EV.Database.Query(sql, params) return MySQL.query.await(sql, params or {}) end
function EV.Database.Single(sql, params) return MySQL.single.await(sql, params or {}) end
function EV.Database.Update(sql, params) return MySQL.update.await(sql, params or {}) end
function EV.Database.Insert(sql, params) return MySQL.insert.await(sql, params or {}) end
function EV.Database.Transaction(queries) return MySQL.transaction.await(queries) end
