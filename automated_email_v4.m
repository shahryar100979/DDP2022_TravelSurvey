function automated_email_v4(behi)

% parameters
mail = 'info@busscos.com'; % my gmail address
password = 'ojhrhydygibyfmrr';  % my gmail password
host = 'smtp.gmail.com';

Subject = 'Do not Miss the Commute Challenge';


setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);
% Gmail server.
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');


for it_com = 1:size(behi,1)


    email_txt_to_users = {'Hello', ...
        '', ...
        'Thanks for signing up to the Commute Challenge by the city and county of Denver, to join the challenge and receive up to $125 rewards, please fill out the two steps survey, only takes 5 min.' , ... 
        '', ...
        'To fill out the surveys, log in to your account at https://www.commuteopt.com/login then navigate to commute information and commute needs survey tabs.' , ...
        'Please fill out the two steps survey before July 1st.' , ... 
        '',...
        'Let us know if you have any questions.'} ;

%     sendto = {'shahryar.monghasemi@gmail.com'};
    sendto = {behi(it_com,1)};

    % send email with attachment to recipients
    sendmail(sendto, Subject, email_txt_to_users)
end
