clear; close all;

%% obtain symbolic expression for y1dd & y2dd
syms y1 y2 y1d y2d L0 k1 k2 k3 m1 m2 F(t)

d1 = sqrt(L0^2+y1^2)-L0;
d2 = sqrt(L0^2+(y2-y1)^2)-L0;
d3 = sqrt(L0^2+y2^2)-L0;

V1 = 0.5*k1*d1^2;
V2 = 0.5*k2*d2^2;
V = T1 + T2;

T1 = 0.5*m1*y1d^2;
T2 = 0.5*m2*y2d^2;
T = T1 + T2;

L = T - V;

y1dd = (1/m1)*(diff(L,y1)+F(t));
y2dd = (1/m2)*diff(L,y2);

%% values
L_initial = 1;
k = [5 5 5];
m = [1 1];
initial_conditions = [0 0 0 0];
w = 5;
Fmag = 20;
tend = 10;
step = 0.05;

%% variables
t = 0:step:tend;
% F_t = t;

% ode45
[t,u] = ode45(@(t,u)rhs(t,u,m,k,L_initial,Fmag,w,y1dd,y2dd), t, initial_conditions);

% plot results
figure; 
subplot(2,1,1); plot(t,u(:,1),'g',t,u(:,2),'r');
xlabel('t'); ylabel('y', 'Rotation',0, 'VerticalAlignment','middle','HorizontalAlignment','right');
legend('y1','y2');

% subplot(3,1,2); plot(t,u(:,3),'g',t,u(:,4),'r');
% xlabel('t'); ylabel('dy/dt', 'Rotation',0, 'VerticalAlignment','middle','HorizontalAlignment','right'); 
% legend('y1d','y2d');

F = -Fmag*sin(w*t);
subplot(2,1,2); plot(t,F,'b');
xlabel('t'); ylabel('F', 'Rotation',0, 'VerticalAlignment','middle','HorizontalAlignment','right'); 
legend('F');

%% video
fps = 20; %number of frames per seconds 

fig = figure;  %open a new figure 
mov = VideoWriter('D_2m','MPEG-4');  %set-up the video file 
mov.FrameRate = fps; %set the rate of frames 
open(mov);  %open the video file 

% generate frames
N = tend/step+1;
for k = 1 : N
    % plot mass
    subplot(2,1,1);
    plot(L_initial,u(k,1),'or','MarkerFaceColor','r'); hold on;
    plot(2*L_initial,u(k,2),'ob','MarkerFaceColor','b');
    % plot links
    x1 = [0 L_initial];
    y1 = [0 u(k,1)];
    plot(x1,y1,'k');
    x2 = [L_initial 2*L_initial];
    y2 = [u(k,1) u(k,2)];
    plot(x2,y2,'k'); 
    x3 = [2*L_initial 3*L_initial];
    y3 = [u(k,2) 0];
    plot(x3,y3,'k'); 
    xlim([0,3*L_initial]); ylim([min(min(u(:,1),u(:,2))),max(max(u(:,1),u(:,2)))]);
    xlabel('x'); ylabel('y', 'Rotation',0, 'VerticalAlignment','middle','HorizontalAlignment','right');
    legend('y1','y2');
    hold off;
    % plot y1 y2 against time
    subplot(2,1,2); plot(t(1:k),u(1:k,1),'r',t(1:k),u(1:k,2),'b');
    xlim([0,tend]); ylim([min(min(u(:,1),u(:,2))),max(max(u(:,1),u(:,2)))]);
    xlabel('t'); ylabel('y', 'Rotation',0, 'VerticalAlignment','middle','HorizontalAlignment','right');
    legend('y1','y2');

    drawnow; %updates the figure      
    frame = getframe(fig); %convert the figure into a frame for the video 
    writeVideo(mov,frame); %add frame to video 
end 

close(mov); %close the video file 
close(fig); %close the figure  

%% differential equation to solve 
function dudt = rhs(t,u,m,k,L_initial,Fmag,w,y1dd,y2dd)
    
    % give values to the symbols
    F = -Fmag*sin(w*t);
    L0 = L_initial;
    y1 = u(1);
    y2 = u(2);
    y1d = u(3);
    y2d = u(4);
    m1 = m(1);
    m2 = m(2);
    k1 = k(1);
    k2 = k(2);
    k3 = k(3);

    % evaluate the value of symbolic expression for y1dd & y2dd 
    y1dd = subs(y1dd);              % symbolic substitution
    y2dd = subs(y2dd);
    y1dd = double(vpa(y1dd));       % variable-precision arithmetic, convert to double
    y2dd = double(vpa(y2dd));

    dudt = [u(3); u(4); y1dd; y2dd];
end
