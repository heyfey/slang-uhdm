// § unitClassTdSpecAtName202
virtual class uvm_object;
endclass
class base #(type T=int);
endclass
class uvm_config_db#(type T=int, type T2=int) extends base#(T);
endclass
typedef uvm_config_db#(int, string) m_misc;
module top ();
  m_misc misc1;
endmodule
