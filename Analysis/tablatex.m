function tablatex(matrix)
    
    fid = fopen('table.tex','w');
    
    fprintf(fid,'\\documentclass{article}\n');
    fprintf(fid,'\\begin{document}\n');
    fprintf(fid,' \\begin{tabular}{ |');
    
    for col=1:size(matrix,2)
        fprintf(fid,'l | ');
    end
    fprintf(fid,'}\n\\hline\n');
    
    % now write the elements of the matrix
    for r=1:size(matrix,1)
        for c=1:size(matrix,2)
            if c==size(matrix,2)
                fprintf(fid,'%f',matrix(r,c));
            else
                fprintf(fid,'%f & ',matrix(r,c));
            end
        end            
        
        fprintf(fid,' \\\\ \\hline \n');
    end
    
    
    fprintf(fid,'\\hline\n');
    fprintf(fid,'\\end{tabular}\n');
    fprintf(fid,'\\end{document}\n');
    fclose(fid);
    
    
    return