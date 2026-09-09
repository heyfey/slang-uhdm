// Is the imported-package-parameter constant fold defective in a MODULE too?
package ci_pkg;
  parameter int SHADOW = 5;
endpackage
interface ci_if;                 // uninstantiated interface (the new road)
  import ci_pkg::SHADOW;
  int n;
  initial n = SHADOW;
endinterface
module ci_mod;                   // module def road (pre-existing)
  import ci_pkg::SHADOW;
  int n;
  initial n = SHADOW;
endmodule
interface ci_inst;               // instantiated interface (elab road)
  import ci_pkg::SHADOW;
  int n;
  initial n = SHADOW;
endinterface
module ci_top; ci_inst u(); endmodule
