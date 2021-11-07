function mailugo(body,title)

if nargin < 2
    title = 'MATLAB automated message';
end

A = ['LAB','lab'];
B = 'ugo';
C = 'Iq';
D = 'xeueo';

email = strcat(B,'s',A(4:6));
sss = strcat(C,num2str(1),D,'?!',A(1:3));
serv = '@gmail.com';

num = strcat('618','303','4686');
serv2 = '@vtext.com';

setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','E_mail',strcat(email,serv));
setpref('Internet','SMTP_Username',email);
setpref('Internet','SMTP_Password',sss);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

sendmail(strcat(num,serv2),title,body);

end