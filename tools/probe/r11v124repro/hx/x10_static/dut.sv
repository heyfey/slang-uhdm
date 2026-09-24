// § incDecMemberPathIsLvalue124
class C; static int cnt; endclass
module top; initial C::cnt++; endmodule
