function image_list = read_file(filename)
% function to read file in filename and retrieve text info stored in it

fid=fopen(filename,'r');
tmp=textscan(fid,'%s');
image_list=tmp{1};
fclose(fid);
end
