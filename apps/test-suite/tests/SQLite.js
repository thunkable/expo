'use strict';

import { SQLite, FileSystem as FS, Asset } from 'expo';

export const name = 'SQLite';

// TODO: Only tests successful cases, needs to test error cases like bad database name etc.
export function test(t) {
  t.describe('SQLite', () => {
    t.it('should be able to drop + create a table, insert, query', async () => {
      const db = SQLite.openDatabase('test.db');
      await new Promise((resolve, reject) => {
        db.transaction(
          tx => {
            const nop = () => {};
            const onError = (tx, error) => reject(error);

            tx.executeSql('DROP TABLE IF EXISTS Users;', [], nop, onError);
            tx.executeSql(
              'CREATE TABLE IF NOT EXISTS Users (user_id INTEGER PRIMARY KEY NOT NULL, name VARCHAR(64), k INT, j REAL);',
              [],
              nop,
              onError
            );
            tx.executeSql(
              'INSERT INTO Users (name, k, j) VALUES (?, ?, ?)',
              ['Tim Duncan', 1, 23.4],
              nop,
              onError
            );
            tx.executeSql(
              'INSERT INTO Users (name, k, j) VALUES ("Manu Ginobili", 5, 72.8)',
              [],
              nop,
              onError
            );
            tx.executeSql(
              'INSERT INTO Users (name, k, j) VALUES ("Nikhilesh Sigatapu", 7, 42.14)',
              [],
              nop,
              onError
            );

            tx.executeSql(
              'SELECT * FROM Users',
              [],
              (tx, results) => {
                t.expect(results.rows.length).toEqual(3);
                t.expect(results.rows._array[0].j).toBeCloseTo(23.4);
              },
              onError
            );
          },
          reject,
          resolve
        );
      });

      const { exists } = await FS.getInfoAsync(`${FS.documentDirectory}SQLite/test.db`);
      t.expect(exists).toBeTruthy();
    });

    t.it(
      'should work with a downloaded .db file',
      async () => {
        await FS.downloadAsync(
          Asset.fromModule(require('../assets/asset-db.db')).uri,
          `${FS.documentDirectory}SQLite/downloaded.db`
        );

        const db = SQLite.openDatabase('downloaded.db');
        await new Promise((resolve, reject) => {
          db.transaction(
            tx => {
              const nop = () => {};
              const onError = (tx, error) => reject(error);
              tx.executeSql(
                'SELECT * FROM Users',
                [],
                (tx, results) => {
                  t.expect(results.rows.length).toEqual(3);
                  t.expect(results.rows._array[0].j).toBeCloseTo(23.4);
                },
                onError
              );
            },
            reject,
            resolve
          );
        });
      },
      30000
    );

    t.it('should be able to recreate db from scratch by deleting file', async () => {
      {
        const db = SQLite.openDatabase('test.db');
        await new Promise((resolve, reject) => {
          db.transaction(
            tx => {
              const nop = () => {};
              const onError = (tx, error) => reject(error);

              tx.executeSql('DROP TABLE IF EXISTS Users;', [], nop, onError);
              tx.executeSql(
                'CREATE TABLE IF NOT EXISTS Users (user_id INTEGER PRIMARY KEY NOT NULL, name VARCHAR(64), k INT, j REAL);',
                [],
                nop,
                onError
              );
              tx.executeSql(
                'INSERT INTO Users (name, k, j) VALUES (?, ?, ?)',
                ['Tim Duncan', 1, 23.4],
                nop,
                onError
              );

              tx.executeSql(
                'SELECT * FROM Users',
                [],
                (tx, results) => {
                  t.expect(results.rows.length).toEqual(1);
                },
                onError
              );
            },
            reject,
            resolve
          );
        });
      }

      {
        const { exists } = await FS.getInfoAsync(`${FS.documentDirectory}SQLite/test.db`);
        t.expect(exists).toBeTruthy();
      }

      {
        await FS.deleteAsync(`${FS.documentDirectory}SQLite/test.db`);
        const { exists } = await FS.getInfoAsync(`${FS.documentDirectory}SQLite/test.db`);
        t.expect(exists).toBeFalsy();
      }

      {
        const db = SQLite.openDatabase('test.db');
        await new Promise((resolve, reject) => {
          db.transaction(
            tx => {
              const nop = () => {};
              const onError = (tx, error) => reject(error);

              tx.executeSql('DROP TABLE IF EXISTS Users;', [], nop, onError);
              tx.executeSql(
                'CREATE TABLE IF NOT EXISTS Users (user_id INTEGER PRIMARY KEY NOT NULL, name VARCHAR(64), k INT, j REAL);',
                [],
                nop,
                onError
              );
              tx.executeSql(
                'SELECT * FROM Users',
                [],
                (tx, results) => {
                  t.expect(results.rows.length).toEqual(0);
                },
                onError
              );

              tx.executeSql(
                'INSERT INTO Users (name, k, j) VALUES (?, ?, ?)',
                ['Tim Duncan', 1, 23.4],
                nop,
                onError
              );
              tx.executeSql(
                'SELECT * FROM Users',
                [],
                (tx, results) => {
                  t.expect(results.rows.length).toEqual(1);
                },
                onError
              );
            },
            reject,
            resolve
          );
        });
      }
    });

    t.it('should maintain correct type of potentialy null bind parameters', async () => {
      const db = SQLite.openDatabase('test.db');
      await new Promise((resolve, reject) => {
        db.transaction(
          tx => {
            const nop = () => {};
            const onError = (tx, error) => reject(error);

            tx.executeSql('DROP TABLE IF EXISTS Nulling;', [], nop, onError);
            tx.executeSql(
              'CREATE TABLE IF NOT EXISTS Nulling (id INTEGER PRIMARY KEY NOT NULL, x NUMERIC, y NUMERIC)',
              [],
              nop,
              onError
            );
            tx.executeSql('INSERT INTO Nulling (x, y) VALUES (?, ?)', [null, null], nop, onError);
            tx.executeSql('INSERT INTO Nulling (x, y) VALUES (null, null)', [], nop, onError);

            tx.executeSql(
              'SELECT * FROM Nulling',
              [],
              (tx, results) => {
                t.expect(results.rows._array[0].x).toBeNull();
                t.expect(results.rows._array[0].y).toBeNull();
                t.expect(results.rows._array[1].x).toBeNull();
                t.expect(results.rows._array[1].y).toBeNull();
              },
              onError
            );
          },
          reject,
          resolve
        );
      });

      const { exists } = await FS.getInfoAsync(`${FS.documentDirectory}SQLite/test.db`);
      t.expect(exists).toBeTruthy();
    });

    t.it('should support PRAGMA statements', async () => {
      const db = SQLite.openDatabase('test.db');
      await new Promise((resolve, reject) => {
        db.transaction(
          tx => {
            const nop = () => {};
            const onError = (tx, error) => reject(error);

            tx.executeSql('DROP TABLE IF EXISTS SomeTable;', [], nop, onError);
            tx.executeSql(
              'CREATE TABLE IF NOT EXISTS SomeTable (id INTEGER PRIMARY KEY NOT NULL, name VARCHAR(64));',
              [],
              nop,
              onError
            );
            // a result-returning pragma
            tx.executeSql(
              'PRAGMA table_info(SomeTable);',
              [],
              (tx, results) => {
                t.expect(results.rows.length).toEqual(2);
                t.expect(results.rows._array[0].name).toEqual('id');
                t.expect(results.rows._array[1].name).toEqual('name');
              },
              onError
            );
            // a no-result pragma
            tx.executeSql('PRAGMA case_sensitive_like = true;', [], nop, onError);
            // a setter/getter pragma
            tx.executeSql('PRAGMA user_version = 123;', [], nop, onError);
            tx.executeSql(
              'PRAGMA user_version;',
              [],
              (tx, results) => {
                t.expect(results.rows.length).toEqual(1);
                t.expect(results.rows._array[0].user_version).toEqual(123);
              },
              onError
            );
          },
          reject,
          resolve
        );
      });
    });
  });
}
