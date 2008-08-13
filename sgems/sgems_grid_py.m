function [py_script,S,XML]=sgems_grid_py(S,py_script);

if nargin<1
    S.xml_file='sgsim.par'; % GET DEF PAR FILE
end

if isfield(S,'xml_file')==0
    S.xml_file=sgems_write_xml(S);
end

if isfield(S,'XML')
    S.xml_file=sgems_write_xml(S.XML);
end

if ~isfield(S,'dim'), S.dim.null=0;end
if ~isfield(S.dim,'nx');S.dim.nx=100;end
if ~isfield(S.dim,'ny');S.dim.ny=100;end
if ~isfield(S.dim,'nz');S.dim.nz=1;end

if ~isfield(S.dim,'dx');S.dim.dx=1;end
if ~isfield(S.dim,'dy');S.dim.dy=1;end
if ~isfield(S.dim,'dz');S.dim.dz=1;end

if ~isfield(S.dim,'x0');S.dim.x0=0;end
if ~isfield(S.dim,'y0');S.dim.y0=0;end
if ~isfield(S.dim,'z0');S.dim.z0=0;end


if nargin<2;
   py_script='sgems.py';
end

% HARD DATA ?
if isfield(S,'d_obs');
    write_eas('obs.eas',S.d_obs);
    S.f_obs='obs.eas';
end

if isfield(S,'f_obs');
    [d_obs,h_obs]=read_eas(S.f_obs);
    keyboard
    %
    %
end



% read XML struc
[XML]=sgems_read_xml(S.xml_file);
% read XML as character array
fid=fopen(S.xml_file,'r');
xml_string=char(fread(fid,'char')');
xml_string=regexprep(xml_string,char(10),''); % remove line change
xml_string=regexprep(xml_string,char(13),''); % remove line change
fclose(fid);



fid=fopen(py_script,'w');

grid_name=XML.parameters.Grid_Name.value;
property_name=XML.parameters.Property_Name.value;
nsim=XML.parameters.Nb_Realizations.value;


i=0;
i=i+1;sgems_cmd{i}=sprintf('sgems.execute(''DeleteObjects %s'')',grid_name);
i=i+1;sgems_cmd{i}='sgems.execute(''DeleteObjects finished'')';
i=i+1;sgems_cmd{i}=sprintf('sgems.execute(''NewCartesianGrid  %s::%d::%d::%d::%g::%g::%g::%g::%g::%g'')',grid_name,S.dim.nx,S.dim.ny,S.dim.nz,S.dim.dx,S.dim.dy,S.dim.dz,S.dim.x0,S.dim.y0,S.dim.z0);
if isfield(S,'f_obs')
    i=i+1;sgems_cmd{i}=sprintf('sgems.execute(''LoadObjectFromFile  %s::All'')',S.f_obs);
end
i=i+1;sgems_cmd{i}=sprintf('sgems.execute(''DeleteObjects finished'')');
i=i+1;sgems_cmd{i}=sprintf('sgems.execute(''RunGeostatAlgorithm  sgsim::/GeostatParamUtils/XML::%s'')',xml_string);
%i=i+1;sgems_cmd{i}=sprintf('SaveGeostatGrid  SIM::%s.out::gslib::0::%s__real0',property_name,property_name)

i=i+1;sgems_cmd{i}=sprintf('\n');

p='';
for j=1:nsim; p=sprintf('%s::%s__real%d',p,property_name,j-1);end
i=i+1;sgems_cmd{i}=sprintf('sgems.execute(''SaveGeostatGrid  SIM::%s.out::gslib::0%s'')',property_name,p);

i=i+1;sgems_cmd{i}=sprintf('\n');


i=i+1;sgems_cmd{i}=sprintf('sgems.execute(''NewCartesianGrid  finished::1::1::1::1.0::1.0::1.0::0::0::0'')');
i=i+1;sgems_cmd{i}=sprintf('data=[]');
i=i+1;sgems_cmd{i}=sprintf('data.append(1)');
i=i+1;sgems_cmd{i}=sprintf('sgems.set_property(''finished'',''dummy'',data)');

i=i+1;sgems_cmd{i}=sprintf('sgems.execute(''SaveGeostatGrid  finished::finished::gslib::0::dummy'')');

%SaveGeostatGrid  SIM::c:/RESEARCH/PROGRAMMING/mGstat/sgems/SIMTEST.eas::gslib::0::SIM4__real0::SIM4__real1
%SaveGeostatGrid  SIM::c:/RESEARCH/PROGRAMMING/mGstat/sgems/test.out::gslib::0::SIM4__real0::SIM4__real1

fprintf(fid,'import sgems\n\n');

for i=1:length(sgems_cmd)
    %fprintf(fid,'sgems.execute(''%s'')\n',sgems_cmd{i});
    fprintf(fid,'%s\n',sgems_cmd{i});
end

fclose(fid);