// r10vbuvm16 arm v5 — STRESS: shapes that could crash the symbol walk or open
// the window somewhere unexpected.
package vpk5;

  int gp5;
  int gda5[] = new[4];              // v5_pkg_var_init (package-scope new[])

  class s5;
    int sda[];
    static int sst;
    static int ssda[];
    rand int rv;
    int rq[$];
    typedef struct { int f1; int f2; } st5_t;
    st5_t stv;
    extern static function void sfn(int sf5);
    extern function void rndz(int rz5);
    extern function void statvar();
    extern function void autostat();
    extern function void manyblk();
    extern function void assocv();
    extern function void chained();
    extern function void castsz(int cs5);
    extern function void strsz(string ss5);
    extern function void realsz(real rs5);
    extern function void selfsz();
    extern function void twonew(int tn5);
  endclass

  function void s5::sfn(int sf5);          // STATIC method
    int sl5;
    ssda = new[sf5 + sl5 + sst];           // v5_static_method
  endfunction

  function void s5::rndz(int rz5);
    int rl5;
    void'(this.randomize());
    sda = new[rz5 + rl5 + rv];             // v5_after_randomize (rv is rand prop)
  endfunction

  function void s5::statvar();
    static int stl5 = 0;                   // a STATIC lifetime local
    sda = new[stl5];                       // v5_static_local
  endfunction

  function automatic void s5::autostat();
    automatic int al5 = 1;
    sda = new[al5];                        // v5_automatic_local
  endfunction

  function void s5::manyblk();
    begin : b1
      begin : b2
        begin
          begin : b4
            int deep5;
            sda = new[deep5];              // v5_four_deep_blocks
          end
        end
      end
    end
  endfunction

  function void s5::assocv();
    int amap5[string];
    string k5;
    sda = new[amap5[k5]];                  // v5_assoc_index
  endfunction

  function void s5::chained();
    int c5;
    sda = new[c5];
    sda = new[sda.size()];                 // v5_self_size
    sda = new[sda.size()](sda);            // v5_self_copy
  endfunction

  function void s5::castsz(int cs5);
    sda = new[int'(cs5)];                  // v5_cast
  endfunction

  function void s5::strsz(string ss5);
    sda = new[ss5.len()];                  // v5_string_len_formal
  endfunction

  function void s5::realsz(real rs5);
    sda = new[int'(rs5)];                  // v5_real_cast
  endfunction

  function void s5::selfsz();
    int q5[$];
    sda = new[q5.size() + q5.sum()];       // v5_queue_methods_local
  endfunction

  function void s5::twonew(int tn5);
    int a5[]; int b5[];
    a5 = new[tn5];
    b5 = new[tn5](a5);                     // v5_two_arg_copy_formal
  endfunction

  // a virtual/abstract class and an interface class, in a package
  virtual class vabs5;
    int vda5[];
    pure virtual function void pvf(int p5);
    extern function void cvf(int c5);
  endclass
  function void vabs5::cvf(int c5);
    int cl5;
    vda5 = new[c5 + cl5];                  // v5_virtual_class_oob
  endfunction

endpackage
