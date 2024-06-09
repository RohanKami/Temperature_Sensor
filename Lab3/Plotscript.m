
try
fclose(instrfind);
end;

clear


s1 = serial('COM5', ... % Change as needed!
'BaudRate', 115200, ...
'Parity', 'none', ...
'DataBits', 8, ...
'StopBits', 1, ...
'FlowControl', 'none');
time=0:100;
result=0*(0:100);
haxes = gca
hLine = plot(time,result);
stripchart('Initialize',gca)




fopen(s1);

val=fscanf(s1);
try
fprintf('Press CTRL+C to finish\n');
while (1)
val=fscanf(s1);


result = sscanf(val, '%f');
result=result/10000000000;
%time=time+1
stripchart('Update',hLine,result)

%fprintf('T=%5.4fC\n', result);


end
end
fclose(s1); 


