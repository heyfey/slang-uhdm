// § tfDeclOnlyBodyBegin412
module msl;
    function void f1();
        int a1;
        int a2;
    endfunction
    function int f2();
        int a1, a2;
    endfunction
    function int f3();
        int a1;
        int a2;
        return a1;
    endfunction
    task t7();
        int a1, a2;
    endtask
endmodule
