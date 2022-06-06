# QLDB Minidriver

As of yet, Amazon has failed to provide a QLDB driver for Ruby, so this is a barebone implementation of it.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add aws-qldb-mini_driver

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install aws-qldb-mini_driver

AWS credetials are expected to be in place, e.g.

```
Aws.config.update({credentials: Aws::Credentials.new('your_access_key_id', 'your_secret_access_key'))
```

## Usage

Start a QLDB session
```
session = Aws::Qldb::MiniDriver::Session.start('sampleLedgerName')
```

Start a transaction
```
transaction = session.start_transaction
```

Execute a PartiQL query (returns the entire response parsed into AWS-objects)

*Parametrized queries and queries with binary attachments are currently not supported*
```
response = transaction.execute("CREATE TABLE test;")
```

Execute an INSERT PartiQL query, which returns the new documentId on success
```
new_document_id = transaction.insert("INSERT INTO test VALUE { 'name' : 'Name' }")
```

Commit a transaction
```
transaction.commit
```

Abort a transaction
```
transaction.abort
```
