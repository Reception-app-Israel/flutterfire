// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mock.dart';

const String testString = 'Hello World';
const String testBucket = 'test-bucket';
const String testFullPath = 'foo/bar';
const String testName = 'test-name';
const String testParent = 'test-parent';
const String testDownloadUrl = 'test-download-url';
const Map<String, dynamic> testMetadataMap = <String, dynamic>{
  'contentType': 'gif'
};
const int testMaxResults = 1;
const String testPageToken = 'test-page-token';

MockReferencePlatform mockReference = MockReferencePlatform();
MockListResultPlatform mockListResultPlatform = MockListResultPlatform();
MockUploadTaskPlatform mockUploadTaskPlatform = MockUploadTaskPlatform();
MockDownloadTaskPlatform mockDownloadTaskPlatform = MockDownloadTaskPlatform();

Future<void> main() async {
  setupFirebaseStorageMocks();
  /*late*/ FirebaseStorage storage;
  /*late*/ Reference testRef;
  FullMetadata testFullMetadata = FullMetadata(testMetadataMap);
  ListOptions testListOptions =
      const ListOptions(maxResults: testMaxResults, pageToken: testPageToken);

  SettableMetadata testSettableMetadata = SettableMetadata();
  File testFile = await createFile('foo.txt');

  group('$Reference', () {
    setUpAll(() async {
      FirebaseStoragePlatform.instance = kMockStoragePlatform;

      await Firebase.initializeApp();
      storage = FirebaseStorage.instance;

      // delegate method mocks
      when(kMockStoragePlatform.ref(any)).thenReturn(mockReference);

      testRef = storage.ref();
    });

    group('.bucket', () {
      test('verify delegate method is called', () {
        when(mockReference.bucket).thenReturn(testBucket);

        final result = testRef.bucket;

        expect(result, isA<String>());
        expect(result, testBucket);

        verify(mockReference.bucket);
      });
    });

    group('.fullPath', () {
      test('verify delegate method is called', () {
        when(mockReference.fullPath).thenReturn(testFullPath);

        final result = testRef.fullPath;

        expect(result, isA<String>());
        expect(result, testFullPath);

        verify(mockReference.fullPath);
      });
    });

    group('.name', () {
      test('verify delegate method is called', () {
        when(mockReference.name).thenReturn(testName);

        final result = testRef.name;

        expect(result, isA<String>());
        expect(result, testName);

        verify(mockReference.name);
      });
    });

    group('.parent', () {
      test('verify delegate method is called', () {
        when(mockReference.parent).thenReturn(mockReference);

        final result = testRef.parent;

        expect(result, isA<Reference>());

        verify(mockReference.parent);
      });
      test('returns null if root', () {
        when(mockReference.parent).thenReturn(null);

        final result = testRef.parent;

        expect(result, isNull);

        verify(mockReference.parent);
      });
    });

    group('.root', () {
      test('verify delegate method is called', () {
        when(mockReference.root).thenReturn(mockReference);

        final result = testRef.root;

        expect(result, isA<Reference>());

        verify(mockReference.root);
      });
    });

    group('child()', () {
      test('verify delegate method is called', () {
        when(mockReference.child(testFullPath)).thenReturn(mockReference);

        final result = testRef.child(testFullPath);

        expect(result, isA<Reference>());

        verify(mockReference.child(testFullPath));
      });

      test('throws AssertionError if path is null', () {
        expect(() => testRef.child(null), throwsAssertionError);
      });
    });

    group('delete()', () {
      test('verify delegate method is called', () async {
        when(mockReference.delete()).thenAnswer((_) => Future.value());

        await testRef.delete();

        verify(mockReference.delete());
      });
    });

    group('getDownloadURL()', () {
      test('verify delegate method is called', () async {
        when(mockReference.getDownloadURL())
            .thenAnswer((_) => Future.value(testDownloadUrl));

        final result = await testRef.getDownloadURL();

        expect(result, isA<String>());
        expect(result, testDownloadUrl);

        verify(mockReference.getDownloadURL());
      });
    });

    group('getMetadata()', () {
      test('verify delegate method is called', () async {
        when(mockReference.getMetadata())
            .thenAnswer((_) => Future.value(testFullMetadata));

        final result = await testRef.getMetadata();

        expect(result, isA<FullMetadata>());
        expect(result.contentType, testMetadataMap['contentType']);

        verify(mockReference.getMetadata());
      });
    });

    group('list()', () {
      test('verify delegate method is called', () async {
        when(mockReference.list(testListOptions))
            .thenAnswer((_) => Future.value(mockListResultPlatform));
        final result = await testRef.list(testListOptions);

        expect(result, isA<ListResult>());

        verify(mockReference.list(testListOptions));
      });

      test('throws AssertionError if max results is not greater than 0', () {
        ListOptions listOptions =
            const ListOptions(maxResults: 0, pageToken: testPageToken);
        expect(() => testRef.list(listOptions), throwsAssertionError);
      });

      test('throws AssertionError if max results is greater than 1000', () {
        ListOptions listOptions =
            const ListOptions(maxResults: 1001, pageToken: testPageToken);

        expect(() => testRef.list(listOptions), throwsAssertionError);
      });
    });

    group('listAll()', () {
      test('verify delegate method is called', () async {
        when(mockReference.listAll())
            .thenAnswer((_) => Future.value(mockListResultPlatform));

        final result = await testRef.listAll();

        expect(result, isA<ListResult>());

        verify(mockReference.listAll());
      });
    });

    group('put()', () {
      test('verify delegate method is called', () {
        List<int> list = utf8.encode('hello world');

        Uint8List data = Uint8List.fromList(list);

        when(mockReference.putData(data)).thenReturn(mockUploadTaskPlatform);

        final result = testRef.putData(data);

        expect(result, isA<Task>());

        verify(mockReference.putData(data));
      });

      test('throws AssertionError if buffer is null', () {
        expect(() => testRef.putData(null), throwsAssertionError);
      });
    });

    group('putBlob()', () {
      test('verify delegate method is called', () {
        when(mockReference.putBlob(testFile))
            .thenReturn(mockUploadTaskPlatform);

        final result = testRef.putBlob(testFile);

        expect(result, isA<Task>());

        verify(mockReference.putBlob(testFile));
      });

      test('throws AssertionError if blob is null', () {
        expect(() => testRef.putBlob(null), throwsAssertionError);
      });
    });

    group('putFile()', () {
      test('verify delegate method is called', () {
        when(mockReference.putFile(testFile))
            .thenReturn(mockUploadTaskPlatform);

        final result = testRef.putFile(testFile);

        expect(result, isA<Task>());

        verify(mockReference.putFile(testFile));
      });

      test('throws AssertionError if file is null', () {
        expect(() => testRef.putFile(null), throwsAssertionError);
      });

      test('throws AssertionError if file does not exists', () async {
        File file = await createFile('delete-me');
        file.deleteSync();

        expect(() => testRef.putFile(file), throwsAssertionError);
      });
    });

    group('putString()', () {
      when(mockReference.putString(any, any, any))
          .thenReturn(mockUploadTaskPlatform);
      test('raw string values', () {
        final result = testRef.putString(testString);

        expect(result, isA<Task>());

        // confirm raw string was converted to a Base64 format
        String data = base64.encode(utf8.encode(testString));
        verify(mockReference.putString(data, PutStringFormat.base64));
      });

      test('data_url format', () {
        UriData uriData = UriData.fromString(testString, base64: true);
        Uri uri = uriData.uri;
        final result =
            testRef.putString(uri.toString(), format: PutStringFormat.dataUrl);

        expect(result, isA<Task>());

        // confirm data_url was converted to a Base64 format
        UriData uriDataExpected = UriData.fromUri(Uri.parse(uri.toString()));
        verify(mockReference.putString(
            uriDataExpected.contentText, PutStringFormat.base64, any));
      });

      test('throws AssertionError if data_url is not a Base64 format', () {
        UriData uriData = UriData.fromString(testString);
        Uri uri = uriData.uri;
        expect(
            () => testRef.putString(uri.toString(),
                format: PutStringFormat.dataUrl),
            throwsAssertionError);
      });

      test('throws AssertionError if data is null', () {
        expect(() => testRef.putString(null), throwsAssertionError);
      });

      test('throws AssertionError if format is null', () {
        expect(() => testRef.putString(testString, format: null),
            throwsAssertionError);
      });
    });

    group('updateMetadata()', () {
      test('verify delegate method is called', () async {
        when(mockReference.updateMetadata(testSettableMetadata))
            .thenAnswer((_) => Future.value(testFullMetadata));

        final result = await testRef.updateMetadata(testSettableMetadata);

        expect(result, isA<FullMetadata>());
        expect(result.contentType, 'gif');

        verify(mockReference.updateMetadata(testSettableMetadata));
      });

      test('throws AssertionError if metadata is null', () {
        expect(() => testRef.updateMetadata(null), throwsAssertionError);
      });
    });

    group('writeToFile()', () {
      test('verify delegate method is called', () {
        when(mockReference.writeToFile(testFile))
            .thenReturn(mockDownloadTaskPlatform);

        final result = testRef.writeToFile(testFile);

        expect(result, isA<Task>());

        verify(mockReference.writeToFile(testFile));
      });

      test('throws AssertionError if file is null', () {
        expect(() => testRef.writeToFile(null), throwsAssertionError);
      });
    });

    test('hashCode()', () {
      expect(testRef.hashCode, hashValues(storage, testFullPath));
    });

    test('toString()', () {
      expect(
        testRef.toString(),
        '$Reference(app: $defaultFirebaseAppName, fullPath: $testFullPath)',
      );
    });
  });
}
