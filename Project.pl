% Author: Phillip Cole
%         Jermaine Coates
%         Jamille Bowen
%         Joe-Wayne Davis
% Date: 20/10/2018

:- use_module(library(pce)).
%Enables the program to make it so that we add another fact with the following predicates
:- dynamic riskrace/1.
:- dynamic count/2.

%Declares facts
riskrace(black).

%first parameter - counts hypertension
%second parameter - counts number of user
count(0,0).

desttorier(E):-
    free(E),
    main_command.

main_command:-
    new(E, dialog('Expert System')),
    send(E, append,
         button('Add a Record',
                message(@prolog, general_info, E))),
    send(E, append,
         button('Add a Ethnicity',
                message(@prolog, add_race,  E))),

    send(E, append,
         button(cancel, message(E, destroy))),
     send(E, open).

add_race(E):-
    free(E),
    new(D, dialog('Expert System')),
    send(D, append(new(Race1, text_item('Enter Ethnicity')))),
    send(D, append,
         button('Add a Record',
                message(@prolog, add_race_action,
                       D,
                       Race1?selection))),
    send(D, append,
         button(cancel, message(D, destroy))),
     send(D, open).


%Adds another fact with the riskrace predicate
add_race_action(D,Race1):- free(D),

    riskrace(Race1) ->
        new(E, dialog('Expert System')),
        send(E, append(new(_, text('Race already recorded')))),
        send(E, append,button('Return to Main Menu', message(@prolog, desttorier,E))),
        send(E, append,button(cancel, message(E, destroy))),
        send(E, open);
    assert(riskrace(Race1)),desttorier(E).

general_info(E):-
    free(E),
    new(D, dialog('Expert System')),

    send(D, append(new(FName, text_item('First Name')))),
    send(D, append(new(LName, text_item('Last Name')))),
    send(D, append(new(Age, int_item(age)))),
    send(D, append(new(Ethnicity, text_item(ethnicity)))),
    send(D, append(new(Gender, menu(gender)))),

    send(D, append(new(Smoke, menu('Do you smoke taboo?')))),
    send(D, append(new(Fam, menu('Does high blood pressure run in your family?')))),
    send(D, append(new(Alcohol, menu('Do you drink more than 2 alcoholic beverages a day?')))),

    send(D, append, new(_, text('Enter your height in two sections:'))),
    send(D, append(new(Feet,int_item(feet)))),
    send(D, append(new(Inches,int_item(inches, low := 0, high := 11)))),

    send(D, append, new(_, text(''))),
    send(D, append, new(Weightlb, int_item('Enter your weight:'))),

    send(D, append,
         button(calculate,
                message(@prolog, logics,
                        D,
                        FName?selection,
                        LName?selection,
                        Age?selection,
                        Ethnicity?selection,
                        Gender?selection,
                        Smoke?selection,
                        Fam?selection,
                        Alcohol?selection,
                        Feet?selection,
                        Inches?selection,
                        Weightlb?selection))),

    send(D, append,
         button(cancel, message(D, destroy))),

    send_list(Gender, append, [male, female]),
    send_list(Smoke, append, [yes, no]),
    send_list(Alcohol, append, [yes, no]),
    send_list(Fam, append, [yes, no]),

    send(D, open).

logics(D, FName, LName, Age, Ethnicity, Gender, Smoke, Fam, Alcohol, Feet, Inches, Weightlb):-
    free(D),
    comp_inches(Feet,Inches,Heightft),
    comp_height(Heightft,Height),
    comp_weight(Weightlb,Weight),
    comp_BMI(Height,Weight,BMI),
    comp_status(BMI,Status),%Fac_Total is 0,
    risk_factor(Smoke,BMI,Ethnicity,Fam,Alcohol,Fac_Total),

    comp_HT(FName, LName, Age, Ethnicity, Gender, Height, Weightlb, BMI, Status, Smoke, Fam, Alcohol,Fac_Total).


%converts Feets into Inches and adds it to get a total of inches
comp_inches(Feet,Inches,Heightft):- Heightft is (Feet * 12) + Inches.

%converts the inches total into cms
comp_height(Heightft,Height):- Height is Heightft / 39.37.

%converts the lbs into kg
comp_weight(Weightlb,Weight):- Weight is Weightlb / 2.205.

%calculates the BMI based on weight and height
comp_BMI(Height,Weight,BMI):- BMI is (Weight / Height) / Height.

%Determines the health status of the user based on the BMI
comp_status(BMI,Status):-
    BMI>=18.5,BMI=<24.9-> Status = 'Normal Weight';
    BMI>=25.0,BMI=<29.9-> Status = 'Overweight';
    BMI>=30.0,BMI=<39.9-> Status = 'Obese';
    BMI>=40.0-> Status = 'Extremely Obese';
    BMI=<18.5-> Status = 'Under Weight'.

%Collects the user blood pressure readings
comp_HT(FName, LName, Age, Ethnicity, Gender, Height, Weight, BMI, Status, Smoke, Fam, Alcohol,Fac_Total):-
        Fac_Total>=3->new(H, dialog('Warning')),
        send(H, append,(new(_, menu('You are at risk of Hypertension')))),
        send(H, append,(new(Systolic, int_item('Enter your systolic blood pressure reading (mm Hg)')))),
        send(H, append,(new(Diastolic, int_item('Enter your diastolic blood pressure reading (mm Hg)')))),
            send(H, append,
             button(calculate,
                    message(@prolog, comp_Hyper,
                            H,
                            Systolic?selection,
                            Diastolic?selection,
                            FName,
                            LName,
                            Age,
                            Ethnicity,
                            Gender,
                            Height,
                            Weight,
                            BMI,
                            Status,
                            Smoke,
                            Fam,
                            Alcohol,Fac_Total))),
         send(H, append,
             button(cancel, message(H, destroy))),
         send(H, open);
         free(H),output(FName, LName, Age, Ethnicity, Gender, Height, Weight, BMI, Status).



try_again( D,FName, LName, Age, Ethnicity, Gender, Height, Weight, BMI, Status, Smoke, Fam, Alcohol,Fac_Total ):-
    free(D),comp_HT(FName, LName, Age, Ethnicity, Gender, Height, Weight, BMI, Status, Smoke, Fam, Alcohol,Fac_Total).

%Determines how the user's blood pressure relates to hypertension based on the blood pressure readings enter by the user
comp_Hyper(H,Systolic, Diastolic, FName, LName, Age, Ethnicity, Gender, Height, Weight, BMI, Status, Smoke, Fam, Alcohol,Fac_Total):-
    free(H),
    Systolic<120,Diastolic<80->
        Pressure = 'normal',
        show_result(BMI, Pressure, FName, LName, Age, Ethnicity, Gender, Height, Weight, Status);
    Systolic>=120,Systolic=<139,Diastolic>80,Diastolic<89->
        Pressure = 'at risk of hypertension(prehypertension)',
        show_result(BMI, Pressure, FName, LName, Age, Ethnicity, Gender, Height, Weight, Status);
    Systolic>=140,Diastolic>=90->
        Pressure = 'high',
        show_result(BMI, Pressure, FName, LName, Age, Ethnicity, Gender, Height, Weight, Status);
    new(D, dialog('Error')),
        send(D, append,(new(_, menu('The value of the Diastolic and Systolic are invalid please try again')))),
            send(D, append,
             button('Try Again',
                    message(@prolog, try_again,
                            D,
                             FName, LName, Age, Ethnicity, Gender, Height, Weight, BMI, Status, Smoke, Fam, Alcohol,Fac_Total ))),
         send(D, append,
             button(cancel, message(D, destroy))),
         send(D, open).

%Calculates the risk factor out of 5 of the user based on pervious data entered by the user
risk_factor(Smoke,BMI,Ethnicity,Fam,Alcohol,Fac_Total):-
    Smoke = 'yes',BMI >=25.0,Fam = 'yes',Alcohol = 'yes',riskrace(Ethnicity)-> Fac_Total is 5;
    Smoke = 'yes',BMI >=25.0,Fam = 'yes',Alcohol = 'yes',not(riskrace(Ethnicity))-> Fac_Total is 4;
    Smoke = 'yes',BMI >=25.0,Fam = 'yes',Alcohol = 'no',not(riskrace(Ethnicity))-> Fac_Total is 3;
    Smoke = 'yes',BMI >=25.0,Fam = 'no',Alcohol = 'no',riskrace(Ethnicity)-> Fac_Total is 2;
    Smoke = 'yes',BMI <25.0,Fam = 'no',Alcohol = 'no',riskrace(Ethnicity)-> Fac_Total is 1;
    Smoke = 'no',BMI =<25.0,Fam = 'no',Alcohol = 'no',riskrace(Ethnicity)-> Fac_Total is 0;
    Smoke = 'no',BMI =<25.0,Fam = 'no',Alcohol = 'no',riskrace(Ethnicity)-> Fac_Total is 1;
    Smoke = 'no',BMI =<25.0,Fam = 'no',Alcohol = 'yes',riskrace(Ethnicity)-> Fac_Total is 2;
    Smoke = 'no',BMI =<25.0,Fam = 'yes',Alcohol = 'yes',riskrace(Ethnicity)-> Fac_Total is 3;
    Smoke = 'no',BMI >=25.0,Fam = 'yes',Alcohol = 'yes',riskrace(Ethnicity)-> Fac_Total is 4.




%shows the results of people with hypertension
show_result(BMI, Pressure, FName, LName, Age, Ethnicity, Gender, Height, Weight, Status):-
    new(E, dialog('Expert System')),

    atom_concat('First Name:', FName, Output_FName),
    send(E, append, new(_, text(Output_FName))),

    atom_concat('Last Name: ', LName, Output_LName),
    send(E, append, new(_, text(Output_LName))),

    atom_concat('Age: ', Age, Output_Age),
    send(E, append, new(_, text(Output_Age))),

    atom_concat('Gender: ', Gender, Output_Gender),
    send(E, append, new(_, text(Output_Gender))),

    atom_concat('Ethnicity: ', Ethnicity, Output_Ethnicity),
    send(E, append, new(_, text(Output_Ethnicity))),

    atom_concat('Height: ', Height, Output_Height),
    send(E, append, new(_, text(Output_Height))),

    atom_concat('Weight: ', Weight, Output_Weight),
    send(E, append, new(_, text(Output_Weight))),

    atom_concat('BMI: ', BMI, Output_BMI),
    send(E, append, new(_, text(Output_BMI))),

    concat('Pressure: ', Pressure, Output_Pressure),
    send(E, append, new(_, text(Output_Pressure))),

    atom_concat('Status: ', Status, Output_Status),
    send(E, append, new(_, text(Output_Status))),


    /*atom_concat('Risk of Hypertension : ', Fac_Total, Output_Fac_Total),
    atom_concat(Output_Fac_Total, '/5', Output_Fac),
    send(E, append, new(_, text(Output_Fac))),*/

    count(Number_of_User, Risk_Number),
    New_Number_of_User is Number_of_User + 1,
    New_Risk_Number is Risk_Number + 1,

    retractall(count(_,_)),
    assert(count(New_Number_of_User,New_Risk_Number)),

    atom_concat('Number of Users: ', New_Number_of_User, Output_User),
    send(E, append, new(_, text(Output_User))),

    atom_concat('Number of Users with Risk of Hypertension: ', New_Risk_Number, Output_Risk),
    send(E, append, new(_, text(Output_Risk))),

    send(E, append,button('Return to Main Menu', message(@prolog, desttorier,E))),

    send(E, append,
        button(cancel, message(E, destroy))),

    send(E, open).

%shows the results of people without hypertension
output(FName, LName, Age, Ethnicity, Gender, Height, Weight, BMI, Status):-
    new(E, dialog('Expert System')),

    atom_concat('First Name:', FName, Output_FName),
    send(E, append, new(_, text(Output_FName))),

    atom_concat('Last Name: ', LName, Output_LName),
    send(E, append, new(_, text(Output_LName))),

    atom_concat('Age: ', Age, Output_Age),
    send(E, append, new(_, text(Output_Age))),

    atom_concat('Gender: ', Gender, Output_Gender),
    send(E, append, new(_, text(Output_Gender))),

    atom_concat('Ethnicity: ', Ethnicity, Output_Ethnicity),
    send(E, append, new(_, text(Output_Ethnicity))),

    atom_concat('Height: ', Height, Output_Height),
    send(E, append, new(_, text(Output_Height))),

    atom_concat('Weight: ', Weight, Output_Weight),
    send(E, append, new(_, text(Output_Weight))),

    atom_concat('BMI: ', BMI, Output_BMI),
    send(E, append, new(_, text(Output_BMI))),

    send(E, append, new(_, text('Pressure: normal'))),

    atom_concat('Status: ', Status, Output_Status),
    send(E, append, new(_, text(Output_Status))),

    count(Number_of_User, Risk_Number),
    New_Number_of_User is Number_of_User + 1,
    New_Risk_Number is Risk_Number,

    retractall(count(_,_)),
    assert(count(New_Number_of_User,New_Risk_Number)),

    atom_concat('Number of Users: ', New_Number_of_User, Output_User),
    send(E, append, new(_, text(Output_User))),

    atom_concat('Number of Users with Risk of Hypertension: ', New_Risk_Number, Output_Risk),
    send(E, append, new(_, text(Output_Risk))),

    send(E, append,button('Return to Main Menu', message(@prolog, desttorier,E))),

    send(E, append,
         button(cancel, message(E, destroy))),

    send(E, open).











