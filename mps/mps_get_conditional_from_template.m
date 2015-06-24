% mps_get_conditional_from_template: Get conditional distritution
%
% Call:
%    [C_PDF,TI]=mps_get_conditional_from_template(TI,V,L)
%
%    TI: training image struct
%       TI.x, TI.y, TI.D
function [C_PDF,N_PDF,TI]=mps_get_conditional_from_template(TI,V,L,COUNT_MAX,COUNT_MIN)
if (nargin<4)
    COUNT_MAX=10;1e+9;
end


N_TI=prod(size(TI.D));
N_COND=length(V);

if ~isfield(TI,'N_CAT');TI.N_CAT=length(unique(TI.D));end

j_start=ceil(rand(1)*N_TI);
j_arr(1:(N_TI-j_start+1))=j_start:1:N_TI;
j_arr((N_TI-j_start+2):N_TI)=1:(j_start-1);

ij=0;
DIS_MIN=1e+5;

C_PDF=zeros(1,TI.N_CAT);


break_flag=0;
count=0;

%% REMEMMBER TO RANDOMIZE START LOCATION

% random start point
ix_1=ceil(rand(1)*TI.nx);
iy_1=ceil(rand(1)*TI.ny);

% create arrays of x and y
ix_arr=circshift(1:1:TI.nx,ix_1,2);
iy_arr=circshift(1:1:TI.ny,iy_1,2);


j=0;
for ix_ti=ix_arr;1:TI.nx;
    for iy_ti=iy_arr;1:TI.ny;
        j=j+1;
        %disp(sprintf('[ix,iy]=[%d,%d] j=%4d',ix_ti,iy_ti,j))
        if N_COND==0;
            iy_ti_min=iy_ti;
            ix_ti_min=ix_ti;
            V_cond=TI.D(iy_ti,ix_ti);
            C_PDF(V_cond+1)=C_PDF(V_cond+1)+1;
            count=count+1;
        else
            
            % COMPUTE DISTANCE
            DIS=0;
            for k=1:size(L,1);
                iy_test=L(k,1)+iy_ti;
                ix_test=L(k,2)+ix_ti;
                
                if ((iy_test>0)&&(iy_test<=TI.ny)&&(ix_test>0)&(ix_test<=TI.nx))
                    if TI.D(iy_test,ix_test)==V(k);
                        DIS=DIS+0;
                    else
                        DIS=DIS+1;
                    end
                else
                    DIS=DIS+1;
                end
            end
            
            if DIS==0
                count=count+1;
                V_cond=TI.D(iy_ti,ix_ti);
                C_PDF(V_cond+1)=C_PDF(V_cond+1)+1;
            end
            
        end
        
        if count>=COUNT_MAX;
            break_flag=1;
            break;
        end
        
    end;
    if (break_flag==1);break;end
end

%end

% prior distribution of counts... C_pdf will never be empty..
%C_PDF_prior=ones(1,TI.N_CAT)./11;
%C_PDF_prior=[0 0]/10;
%C_PDF=C_PDF+C_PDF_prior;

% normalize
N_PDF=sum(C_PDF);
C_PDF=C_PDF./N_PDF;
