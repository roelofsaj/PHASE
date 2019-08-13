testData = [1;1;2;2;3;3;4;4;5;5;6;6;7;7;8;8;9;9;10;10];
testData = [testData testData+10 testData+20 testData+30];
testData(:,:,2) = testData + 100;
testData = testData/2;