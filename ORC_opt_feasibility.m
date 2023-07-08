clear all
%% run ORC_nominal.gms file to get the optimal process design and operating parameters at a nominal condition
g = GAMS(struct('gams','X:\XXX\gams.exe','model','X:\XXX\ORC_nominal.gms')); %the route needs to be specified
g.run; % executes
%read results from the GAMS run
T=GAMS.getGDX('D:\XXX\result.gdx','T_out');T.name='Tini';
P_low=GAMS.getGDX('D:\XXX\result.gdx','P_low_out');P_low.name='P_low_ini';
P_high=GAMS.getGDX('D:\XXX\result.gdx','P_high_out');P_high.name='P_high_ini';
m_wf=GAMS.getGDX('D:\XXX\result.gdx','m_wf_out'); m_wf.name='m_wf_ini';
Z_v=GAMS.getGDX('D:\XXX\result.gdx','Z_v_out');Z_v.name='Z_v_ini';
Z_l=GAMS.getGDX('D:\XXX\result.gdx','Z_l_out');Z_l.name='Z_l_ini';
T_hso_1=GAMS.getGDX('D:\XXX\result.gdx','T_hso_1_out');T_hso_1.name='T_hso_1_ini';
T_hso_2=GAMS.getGDX('D:\XXX\result.gdx','T_hso_2_out');T_hso_2.name='T_hso_2_ini';
T_hso_3=GAMS.getGDX('D:\XXX\result.gdx','T_hso_3_out');T_hso_3.name='T_hso_3_ini';
T_hso_4=GAMS.getGDX('D:\XXX\result.gdx','T_hso_4_out');T_hso_4.name='T_hso_4_ini';
T_hsi_1=GAMS.getGDX('D:\XXX\result.gdx','T_hsi_1_out');T_hsi_1.name='T_hsi_1_ini';
T_hsi_2=GAMS.getGDX('D:\XXX\result.gdx','T_hsi_2_out');T_hsi_2.name='T_hsi_2_ini';
T_hsi_3=GAMS.getGDX('D:\XXX\result.gdx','T_hsi_3_out');T_hsi_3.name='T_hsi_3_ini';
T_hsi_4=GAMS.getGDX('D:\XXX\result.gdx','T_hsi_4_out');T_hsi_4.name='T_hsi_4_ini';
A_eva=GAMS.getGDX('D:\XXX\result.gdx','A_eva_out');A_eva.name='A_eva';
A_cond=GAMS.getGDX('D:\XXX\result.gdx','A_cond_out');A_cond.name='A_cond';
%% perform random line search
point=zeros(1000,3); % 1000 points
for i=1:500
    v=rand(3,1)-0.5;
    v=v/(v'*v)^0.5;
    v1_ini=v(1);v2_ini=v(2);v3_ini=v(3);
    v1  = GAMS.param('v1',v1_ini);
    v2  = GAMS.param('v2',v2_ini);
    v3 = GAMS.param('v3',v3_ini);
    % write to GDX file
    GAMS.putGDX('D:\XXX\input.gdx',v1,v2,v3,T,P_low,P_high,m_wf,Z_v,Z_l,T_hso_1,T_hso_2,T_hso_3,T_hso_4,T_hsi_1,T_hsi_2,T_hsi_3,T_hsi_4,A_eva,A_cond);
    g = GAMS(struct('gams','D:\XXX\gams.exe','model','D:\XXX\ORC_off_design.gms'));
    g.run; % executes
    if GAMS.getGDX('D:\XXX\result.gdx','ssolver').val==1 && GAMS.getGDX('D:\XXX\result.gdx','smodel').val==2
        scale_factor = GAMS.getGDX('D:\XXX\result.gdx','scale_factor').val;
        point((i-1)*2+1,:)=[433+scale_factor*v1_ini*30,291+scale_factor*v2_ini*15,4200+scale_factor*v3_ini*840];
    end
    
    v1  = GAMS.param('v1',-v1_ini);
    v2  = GAMS.param('v2',-v2_ini);
    v3 = GAMS.param('v3',-v3_ini);
    GAMS.putGDX('D:\XXX\input.gdx',v1,v2,v3,T,P_low,P_high,m_wf,Z_v,Z_l,T_hso_1,T_hso_2,T_hso_3,T_hso_4,T_hsi_1,T_hsi_2,T_hsi_3,T_hsi_4,A_eva,A_cond);
    g = GAMS(struct('gams','D:\XXX\gams.exe','model','D:\XXX\ORC_off_design.gms'));
    g.run; % executes
    if GAMS.getGDX('D:\XXX\result.gdx','ssolver').val==1 && GAMS.getGDX('D:\XXX\result.gdx','smodel').val==2
        scale_factor = GAMS.getGDX('D:\XXX\result.gdx','scale_factor').val;
        point((i-1)*2+2,:)=[433-scale_factor*v1_ini*30,291-scale_factor*v2_ini*15,4200-scale_factor*v3_ini*840];
    end
    
end
%% results visualization
figure(1);hold on;
point=point(point(:,1)>0,:);
DT = delaunayTriangulation(point);
tetramesh(DT,'FaceAlpha',0.2,'EdgeAlpha',0.2);
scatter3(point(:,1),point(:,2),point(:,3),'bo');
[k1,av1] = convhull(point(:,1),point(:,2),point(:,3));
trisurf(k1,point(:,1),point(:,2),point(:,3),'FaceColor','cyan')
out=[433+30,291+15,4200+840;433-30,291+15,4200+840;433+30,291-15,4200+840;433+30,291+15,4200-840;433+30,291-15,4200-840;433-30,291-15,4200+840;433-30,291-15,4200-840;433-30,291+15,4200-840];
[k2,av2] = convhull(out(:,1),out(:,2),out(:,3));
trisurf(k2,out(:,1),out(:,2),out(:,3),'FaceAlpha',0.3);
x=point(:,1);y=point(:,2);z=point(:,3);
DT=delaunay(x,y,z);
vol=0;
for i=1:length(DT)
    vol=vol+det([([x(DT(i,2)),y(DT(i,2)),z(DT(i,2))]-[x(DT(i,1)),y(DT(i,1)),z(DT(i,1))])',([x(DT(i,3)),y(DT(i,3)),z(DT(i,3))]-[x(DT(i,1)),y(DT(i,1)),z(DT(i,1))])',([x(DT(i,4)),y(DT(i,4)),z(DT(i,4))]-[x(DT(i,1)),y(DT(i,1)),z(DT(i,1))])'])/6;
end
vol/840/2/30/60 %flexibility index
