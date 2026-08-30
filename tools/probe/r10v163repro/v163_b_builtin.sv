// r10v163 — arm B: THE BUILT-IN FENCE, run WITH Surelog's built-ins (this arm
// must NOT be compiled with -nobuiltin, or golden never registers `mailbox` /
// `semaphore` / `process` under their bare names and the fence has nothing to
// hold back).  Adds the case the pass's own arm cannot reach: a USER class
// whose name COLLIDES with a built-in registry key.
//
// LHS is ALWAYS golden(Surelog); RHS is always ours.

package Pk_Mb;
  class CfgMb;
    int q;
  endclass
  // a user class named exactly like the built-in Surelog registers BARE.
  class mailbox_like #(type TT = int);
    TT t;
  endclass
  class HostMb;
    mailbox#(int) b01_mailbox_in_pkgcls;
    semaphore b02_semaphore_in_pkgcls;
    mailbox_like#(CfgMb) b03_userlike_samepkg;
  endclass
endpackage

package Pk_Rho;
  import Pk_Mb::*;
  class CfgRho;
    int q;
  endclass
  class HostRho;
    mailbox#(CfgRho) b10_mailbox_crosspkg;
    mailbox_like#(CfgRho) b11_userlike_crosspkg;
  endclass
endpackage

class CfgUnitMb;
  int q;
endclass

class UnitHostMb;
  mailbox#(CfgUnitMb) b20_mailbox_unitcls;
  mailbox#(int) b21_mailbox_int_unitcls;
  semaphore b22_semaphore_unitcls;
  process b23_process_unitcls;
  Pk_Mb::mailbox_like#(CfgUnitMb) b24_userlike_scoped;
endclass

module M_mb_v163;
  UnitHostMb u_uh;
  Pk_Mb::HostMb u_hm;
  Pk_Rho::HostRho u_hr;
endmodule
