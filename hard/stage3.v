`ifdef ENABLE_FPU
  input  wire                                 h_ex1_d_s,
  input  wire [8:0]                           h_ex1_d_exp,
  input  wire [24+`PEXT:0]                    h_ex1_d_csa_s, //������
  input  wire [24+`PEXT:0]                    h_ex1_d_csa_c, //������
  input  wire                                 h_ex1_d_zero,
  input  wire                                 h_ex1_d_inf,
  input  wire                                 h_ex1_d_nan,
  input  wire                                 h_fadd_s1_s,
  input  wire [8:0]                           h_fadd_s1_exp,
  input  wire [24+`PEXT:0]                    h_fadd_s1_frac, //������
  input  wire                                 h_fadd_s1_zero,
  input  wire                                 h_fadd_s1_inf,
  input  wire                                 h_fadd_s1_nan,
  output wire                                 h_ex2_d_s,
  output wire [ 8:0]                          h_ex2_d_exp,
  output wire [25+`PEXT:0]                    h_ex2_d_frac, //������
  output wire                                 h_ex2_d_inf,
  output wire                                 h_ex2_d_nan,
  input  wire                                 l_ex1_d_s,
  input  wire [8:0]                           l_ex1_d_exp,
  input  wire [24+`PEXT:0]                    l_ex1_d_csa_s, //������
  input  wire [24+`PEXT:0]                    l_ex1_d_csa_c, //������
  input  wire                                 l_ex1_d_zero,
  input  wire                                 l_ex1_d_inf,
  input  wire                                 l_ex1_d_nan,
  input  wire                                 l_fadd_s1_s,
  input  wire [8:0]                           l_fadd_s1_exp,
  input  wire [24+`PEXT:0]                    l_fadd_s1_frac, //������
  input  wire                                 l_fadd_s1_zero,
  input  wire                                 l_fadd_s1_inf,
  input  wire                                 l_fadd_s1_nan,
  output wire                                 l_ex2_d_s,
  output wire [ 8:0]                          l_ex2_d_exp,
  output wire [25+`PEXT:0]                    l_ex2_d_frac, //������
  output wire                                 l_ex2_d_inf,
  output wire                                 l_ex2_d_nan,
`endif


`ifdef ENABLE_FPU
  fpu2 fpu2h
  (
    .ACLK               (ACLK                   ),
    .RSTN               (RSTN&UNIRSTN           ),
    .ex1_d_s            (h_ex1_d_s              ),
    .ex1_d_exp          (h_ex1_d_exp            ),
    .ex1_d_csa_s        (h_ex1_d_csa_s          ),
    .ex1_d_csa_c        (h_ex1_d_csa_c          ),
    .ex1_d_zero         (h_ex1_d_zero           ),
    .ex1_d_inf          (h_ex1_d_inf            ),
    .ex1_d_nan          (h_ex1_d_nan            ),
    .fadd_s1_s          (h_fadd_s1_s            ),
    .fadd_s1_exp        (h_fadd_s1_exp          ),
    .fadd_s1_frac       (h_fadd_s1_frac         ),
    .fadd_s1_zero       (h_fadd_s1_zero         ),
    .fadd_s1_inf        (h_fadd_s1_inf          ),
    .fadd_s1_nan        (h_fadd_s1_nan          ),
    .ex2_d_s            (h_ex2_d_s              ),
    .ex2_d_exp          (h_ex2_d_exp            ),
    .ex2_d_frac         (h_ex2_d_frac           ),
    .ex2_d_inf          (h_ex2_d_inf            ),
    .ex2_d_nan          (h_ex2_d_nan            )
  );

  fpu2 fpu2l
  (
    .ACLK               (ACLK                   ),
    .RSTN               (RSTN&UNIRSTN           ),
    .ex1_d_s            (l_ex1_d_s              ),
    .ex1_d_exp          (l_ex1_d_exp            ),
    .ex1_d_csa_s        (l_ex1_d_csa_s          ),
    .ex1_d_csa_c        (l_ex1_d_csa_c          ),
    .ex1_d_zero         (l_ex1_d_zero           ),
    .ex1_d_inf          (l_ex1_d_inf            ),
    .ex1_d_nan          (l_ex1_d_nan            ),
    .fadd_s1_s          (l_fadd_s1_s            ),
    .fadd_s1_exp        (l_fadd_s1_exp          ),
    .fadd_s1_frac       (l_fadd_s1_frac         ),
    .fadd_s1_zero       (l_fadd_s1_zero         ),
    .fadd_s1_inf        (l_fadd_s1_inf          ),
    .fadd_s1_nan        (l_fadd_s1_nan          ),
    .ex2_d_s            (l_ex2_d_s              ),
    .ex2_d_exp          (l_ex2_d_exp            ),
    .ex2_d_frac         (l_ex2_d_frac           ),
    .ex2_d_inf          (l_ex2_d_inf            ),
    .ex2_d_nan          (l_ex2_d_nan            )
  );
`endif

`ifdef ENABLE_FPU
module fpu2
(
    input  wire                 ACLK,
    input  wire                 RSTN,
    input  wire                 ex1_d_s,
    input  wire [8:0]           ex1_d_exp,
    input  wire [24+`PEXT:0]    ex1_d_csa_s, //������
    input  wire [24+`PEXT:0]    ex1_d_csa_c, //������
    input  wire                 ex1_d_zero,
    input  wire                 ex1_d_inf,
    input  wire                 ex1_d_nan,
    input  wire                 fadd_s1_s,
    input  wire [8:0]           fadd_s1_exp,
    input  wire [24+`PEXT:0]    fadd_s1_frac, //������
    input  wire                 fadd_s1_zero,
    input  wire                 fadd_s1_inf,
    input  wire                 fadd_s1_nan,
    output wire                 ex2_d_s,
    output wire [8:0]           ex2_d_exp,
    output wire [25+`PEXT:0]    ex2_d_frac, //������
    output wire                 ex2_d_inf,
    output wire                 ex2_d_nan
);
  wire const_one                    = 1'b1;
  wire fadd_w_exp_comp              = fadd_s1_exp>ex1_d_exp?1'b1:1'b0;
  wire [ 8:0] fadd_w_exp_diff0      = fadd_w_exp_comp?(fadd_s1_exp-ex1_d_exp):(ex1_d_exp-fadd_s1_exp);
  wire [ 8:0] fadd_w_exp_diff       = fadd_w_exp_diff0>(9'd25+`PEXT)?(9'd25+`PEXT):fadd_w_exp_diff0; //������
  wire [ 8:0] fadd_w_align_exp      = fadd_w_exp_comp?fadd_s1_exp:ex1_d_exp;
  wire [24+`PEXT:0] fadd_w_s1_align_frac  = fadd_s1_frac>>(fadd_w_exp_comp? 0:fadd_w_exp_diff); //������
  wire [24+`PEXT:0] fadd_w_s2_align_frac  = ex1_d_csa_s >>(ex1_d_zero?(9'd25+`PEXT):fadd_w_exp_comp?fadd_w_exp_diff:0); //������
  wire [24+`PEXT:0] fadd_w_s3_align_frac  = ex1_d_csa_c >>(ex1_d_zero?(9'd25+`PEXT):fadd_w_exp_comp?fadd_w_exp_diff:0); //������
/*wire [25+`PEXT:0] s6_0;*/ wire [25+`PEXT:0] s6_1;   wire [25+`PEXT:0] s6_2;
/*wire [25+`PEXT:0] c6_0;*/ wire [25+`PEXT:0] c6_1;   wire [25+`PEXT:0] c6_2;
/*wire [25+`PEXT:0] s7_0;*/ wire [25+`PEXT:0] s7_1;   wire [25+`PEXT:0] s7_2;
/*wire [25+`PEXT:0] c7_0;*/ wire [25+`PEXT:0] c7_1;   wire [25+`PEXT:0] c7_2;
  wire [25+`PEXT:0] si_x = (fadd_s1_s==ex1_d_s) ? {1'b0,fadd_w_s1_align_frac}:~{1'b0,fadd_w_s1_align_frac};
  wire 	            ci_x = (fadd_s1_s==ex1_d_s) ?  1'b0:1'b1;
  nbit_csa #(26+`PEXT) csa_s6_1 ( .ai( {1'b0,fadd_w_s1_align_frac}), .bi(~{1'b0,fadd_w_s2_align_frac}), .ci(~{1'b0,fadd_w_s3_align_frac}), .so(s6_1), .co(c6_1));
  nbit_csa #(26+`PEXT) csa_s6_2 ( .ai(                        si_x), .bi( {1'b0,fadd_w_s2_align_frac}), .ci( {1'b0,fadd_w_s3_align_frac}), .so(s6_2), .co(c6_2));
  nbit_csa #(26+`PEXT) csa_s7_1 ( .ai(     {c6_1[24+`PEXT:0],1'b1}), .bi(                        s6_1), .ci(   {{(25+`PEXT){1'b0}},1'b1}), .so(s7_1), .co(c7_1));
  nbit_csa #(26+`PEXT) csa_s7_2 ( .ai(     {c6_2[24+`PEXT:0],ci_x}), .bi(                        s6_2), .ci(   {{(25+`PEXT){1'b0}},1'b0}), .so(s7_2), .co(c7_2));
//    assign ex2_d_frac1            =  fadd_w_s1_align_frac+(fadd_w_s2_align_frac+fadd_w_s3_align_frac);
//    assign ex2_d_frac2            =  fadd_w_s1_align_frac-(fadd_w_s2_align_frac+fadd_w_s3_align_frac);
//    assign ex2_d_frac3            = -fadd_w_s1_align_frac+(fadd_w_s2_align_frac+fadd_w_s3_align_frac);
  wire [24+`PEXT:0] ex2_d_frac1     = {c7_1[24+`PEXT:0],1'b0}+s7_1; //������
  wire [25+`PEXT:0] ex2_d_frac2     = {c7_2[24+`PEXT:0],1'b0}+s7_2; //������
  wire r_ex2_d_s                    = (fadd_s1_s==ex1_d_s || ex2_d_frac2[25+`PEXT]) ? fadd_s1_s   : ex1_d_s; //������
  wire [ 8:0] r_ex2_d_exp           = fadd_w_align_exp;
  wire [25+`PEXT:0] r_ex2_d_frac    = (fadd_s1_s!=ex1_d_s && ex2_d_frac2[25+`PEXT]) ? ex2_d_frac1 : ex2_d_frac2; //������
  wire r_ex2_d_inf                  = (~fadd_s1_s & fadd_s1_inf & ~( ex1_d_s   & ex1_d_inf)   & ~ex1_d_nan)
                                    | ( fadd_s1_s & fadd_s1_inf & ~(~ex1_d_s   & ex1_d_inf)   & ~ex1_d_nan)
                                    | (~ex1_d_s   & ex1_d_inf   & ~( fadd_s1_s & fadd_s1_inf) & ~fadd_s1_nan)
                                    | ( ex1_d_s   & ex1_d_inf   & ~(~fadd_s1_s & fadd_s1_inf) & ~fadd_s1_nan) ;
  wire r_ex2_d_nan                  = fadd_s1_nan || ex1_d_nan;
  nbit_register #(1) ex2_d_s_r          ( .ACLK(ACLK), .RSTN(RSTN), .d(r_ex2_d_s   ),  .q(ex2_d_s   ));  //slice 2
  nbit_register #(9) ex2_d_exp_r        ( .ACLK(ACLK), .RSTN(RSTN), .d(r_ex2_d_exp ),  .q(ex2_d_exp ));  //slice 2
  nbit_register #(26+`PEXT)ex2_d_frac_r ( .ACLK(ACLK), .RSTN(RSTN), .d(r_ex2_d_frac),  .q(ex2_d_frac));  //slice 2 //������
  nbit_register #(1) ex2_d_inf_r        ( .ACLK(ACLK), .RSTN(RSTN), .d(r_ex2_d_inf ),  .q(ex2_d_inf ));  //slice 2
  nbit_register #(1) ex2_d_nan_r        ( .ACLK(ACLK), .RSTN(RSTN), .d(r_ex2_d_nan ),  .q(ex2_d_nan ));  //slice 2
endmodule
`endif