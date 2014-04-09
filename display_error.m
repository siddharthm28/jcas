function display_error(filename,image_name,msg)
% function that stops executing while throwing a more descriptive error
error('Function : %s Image: %s Msg: %s \n',filename,image_name,msg);
