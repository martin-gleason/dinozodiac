query = sql.SQL("select {fields} from {table}").format(
    fields=sql.SQL(',').join([
        sql.Identifier('scope_id'),
        sql.Identifier('date'),
        sql.Identifier('scope')
    ]),
    table=sql.Identifier('scopes'))

join_query = sql.SQL("SELECT {fields} FROM {tables} WHERE {id1} = {id2}").format(
    fields=sql.SQL(',').join([
        sql.Identifier(col1),
        sql.Identifier(col2),
    ]),
    tables=sql.SQL(',').join([
      sql.Identifier(pkey),
      sql.Identifier(fkey)
    ]))