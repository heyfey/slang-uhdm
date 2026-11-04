// § unitClassTdEndAtInit202
class obj; endclass
typedef obj obj_t;
module zzz ();
  obj_t a = new;
endmodule
module aaa ();
  obj_t b = new;
  zzz u();
endmodule
