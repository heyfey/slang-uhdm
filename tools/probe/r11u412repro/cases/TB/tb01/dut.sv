// § tfDeclOnlyBodyBegin412
module msl;
    task automatic t1();
        int a1;
    endtask
    task automatic t2();
        int a1;
        int a2;
    endtask
    task automatic t3();
        int a1;
        static int a2;
        automatic int a3;
    endtask
    task t4();
        int a1;
        int a2;
        a1 = 1;
    endtask
    task t5();
        int a1;
        int a2;
        a1 = 1;
        a2 = 2;
    endtask
    task t6();
        int a1;
        a1 = 1;
    endtask
endmodule
