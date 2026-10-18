// § unitOobDefsNotInClass402
class c;
int x;
extern task t(int a);
endclass
task c::t(int a); x = a; endtask
module test;
endmodule
