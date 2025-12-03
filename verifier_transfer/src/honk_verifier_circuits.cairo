use core::circuit::{
    CircuitElement as CE, CircuitInput as CI, CircuitInputs, CircuitModulus, CircuitOutputsTrait,
    EvalCircuitTrait, circuit_add, circuit_inverse, circuit_mul, circuit_sub, u384,
};
use garaga::core::circuit::{AddInputResultTrait2, IntoCircuitInputValue, u288IntoCircuitInputValue};
use garaga::definitions::G1Point;

#[inline(always)]
pub fn run_GRUMPKIN_ZK_HONK_SUMCHECK_SIZE_15_PUB_22_circuit(
    p_public_inputs: Span<u256>,
    p_pairing_point_object: Span<u256>,
    p_public_inputs_offset: u384,
    libra_sum: u384,
    sumcheck_univariates_flat: Span<u256>,
    sumcheck_evaluations: Span<u256>,
    libra_evaluation: u384,
    tp_sum_check_u_challenges: Span<u128>,
    tp_gate_challenges: Span<u128>,
    tp_eta_1: u384,
    tp_eta_2: u384,
    tp_eta_3: u384,
    tp_beta: u384,
    tp_gamma: u384,
    tp_base_rlc: u384,
    tp_alphas: Span<u128>,
    tp_libra_challenge: u384,
    modulus: CircuitModulus,
) -> (u384, u384) {
    // CONSTANT stack
    let in0 = CE::<CI<0>> {}; // 0x1
    let in1 = CE::<CI<1>> {}; // 0x8000
    let in2 = CE::<CI<2>> {}; // 0x9d80
    let in3 = CE::<CI<3>> {}; // 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffec51
    let in4 = CE::<CI<4>> {}; // 0x5a0
    let in5 = CE::<CI<5>> {}; // 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593effffd31
    let in6 = CE::<CI<6>> {}; // 0x240
    let in7 = CE::<CI<7>> {}; // 0x0
    let in8 = CE::<CI<8>> {}; // 0x2
    let in9 = CE::<CI<9>> {}; // 0x3
    let in10 = CE::<CI<10>> {}; // 0x4
    let in11 = CE::<CI<11>> {}; // 0x5
    let in12 = CE::<CI<12>> {}; // 0x6
    let in13 = CE::<CI<13>> {}; // 0x7
    let in14 = CE::<CI<14>> {}; // 0x8
    let in15 = CE::<
        CI<15>,
    > {}; // 0x183227397098d014dc2822db40c0ac2e9419f4243cdcb848a1f0fac9f8000000
    let in16 = CE::<CI<16>> {}; // -0x1 % p
    let in17 = CE::<CI<17>> {}; // 0x11
    let in18 = CE::<CI<18>> {}; // 0x9
    let in19 = CE::<CI<19>> {}; // 0x100000000000000000
    let in20 = CE::<CI<20>> {}; // 0x4000
    let in21 = CE::<
        CI<21>,
    > {}; // 0x10dc6e9c006ea38b04b1e03b4bd9490c0d03f98929ca1d7fb56821fd19d3b6e7
    let in22 = CE::<CI<22>> {}; // 0xc28145b6a44df3e0149b3d0a30b3bb599df9756d4dd9b84a86b38cfb45a740b
    let in23 = CE::<CI<23>> {}; // 0x544b8338791518b2c7645a50392798b21f75bb60e3596170067d00141cac15
    let in24 = CE::<
        CI<24>,
    > {}; // 0x222c01175718386f2e2e82eb122789e352e105a3b8fa852613bc534433ee428b

    // INPUT stack
    let (in25, in26, in27) = (CE::<CI<25>> {}, CE::<CI<26>> {}, CE::<CI<27>> {});
    let (in28, in29, in30) = (CE::<CI<28>> {}, CE::<CI<29>> {}, CE::<CI<30>> {});
    let (in31, in32, in33) = (CE::<CI<31>> {}, CE::<CI<32>> {}, CE::<CI<33>> {});
    let (in34, in35, in36) = (CE::<CI<34>> {}, CE::<CI<35>> {}, CE::<CI<36>> {});
    let (in37, in38, in39) = (CE::<CI<37>> {}, CE::<CI<38>> {}, CE::<CI<39>> {});
    let (in40, in41, in42) = (CE::<CI<40>> {}, CE::<CI<41>> {}, CE::<CI<42>> {});
    let (in43, in44, in45) = (CE::<CI<43>> {}, CE::<CI<44>> {}, CE::<CI<45>> {});
    let (in46, in47, in48) = (CE::<CI<46>> {}, CE::<CI<47>> {}, CE::<CI<48>> {});
    let (in49, in50, in51) = (CE::<CI<49>> {}, CE::<CI<50>> {}, CE::<CI<51>> {});
    let (in52, in53, in54) = (CE::<CI<52>> {}, CE::<CI<53>> {}, CE::<CI<54>> {});
    let (in55, in56, in57) = (CE::<CI<55>> {}, CE::<CI<56>> {}, CE::<CI<57>> {});
    let (in58, in59, in60) = (CE::<CI<58>> {}, CE::<CI<59>> {}, CE::<CI<60>> {});
    let (in61, in62, in63) = (CE::<CI<61>> {}, CE::<CI<62>> {}, CE::<CI<63>> {});
    let (in64, in65, in66) = (CE::<CI<64>> {}, CE::<CI<65>> {}, CE::<CI<66>> {});
    let (in67, in68, in69) = (CE::<CI<67>> {}, CE::<CI<68>> {}, CE::<CI<69>> {});
    let (in70, in71, in72) = (CE::<CI<70>> {}, CE::<CI<71>> {}, CE::<CI<72>> {});
    let (in73, in74, in75) = (CE::<CI<73>> {}, CE::<CI<74>> {}, CE::<CI<75>> {});
    let (in76, in77, in78) = (CE::<CI<76>> {}, CE::<CI<77>> {}, CE::<CI<78>> {});
    let (in79, in80, in81) = (CE::<CI<79>> {}, CE::<CI<80>> {}, CE::<CI<81>> {});
    let (in82, in83, in84) = (CE::<CI<82>> {}, CE::<CI<83>> {}, CE::<CI<84>> {});
    let (in85, in86, in87) = (CE::<CI<85>> {}, CE::<CI<86>> {}, CE::<CI<87>> {});
    let (in88, in89, in90) = (CE::<CI<88>> {}, CE::<CI<89>> {}, CE::<CI<90>> {});
    let (in91, in92, in93) = (CE::<CI<91>> {}, CE::<CI<92>> {}, CE::<CI<93>> {});
    let (in94, in95, in96) = (CE::<CI<94>> {}, CE::<CI<95>> {}, CE::<CI<96>> {});
    let (in97, in98, in99) = (CE::<CI<97>> {}, CE::<CI<98>> {}, CE::<CI<99>> {});
    let (in100, in101, in102) = (CE::<CI<100>> {}, CE::<CI<101>> {}, CE::<CI<102>> {});
    let (in103, in104, in105) = (CE::<CI<103>> {}, CE::<CI<104>> {}, CE::<CI<105>> {});
    let (in106, in107, in108) = (CE::<CI<106>> {}, CE::<CI<107>> {}, CE::<CI<108>> {});
    let (in109, in110, in111) = (CE::<CI<109>> {}, CE::<CI<110>> {}, CE::<CI<111>> {});
    let (in112, in113, in114) = (CE::<CI<112>> {}, CE::<CI<113>> {}, CE::<CI<114>> {});
    let (in115, in116, in117) = (CE::<CI<115>> {}, CE::<CI<116>> {}, CE::<CI<117>> {});
    let (in118, in119, in120) = (CE::<CI<118>> {}, CE::<CI<119>> {}, CE::<CI<120>> {});
    let (in121, in122, in123) = (CE::<CI<121>> {}, CE::<CI<122>> {}, CE::<CI<123>> {});
    let (in124, in125, in126) = (CE::<CI<124>> {}, CE::<CI<125>> {}, CE::<CI<126>> {});
    let (in127, in128, in129) = (CE::<CI<127>> {}, CE::<CI<128>> {}, CE::<CI<129>> {});
    let (in130, in131, in132) = (CE::<CI<130>> {}, CE::<CI<131>> {}, CE::<CI<132>> {});
    let (in133, in134, in135) = (CE::<CI<133>> {}, CE::<CI<134>> {}, CE::<CI<135>> {});
    let (in136, in137, in138) = (CE::<CI<136>> {}, CE::<CI<137>> {}, CE::<CI<138>> {});
    let (in139, in140, in141) = (CE::<CI<139>> {}, CE::<CI<140>> {}, CE::<CI<141>> {});
    let (in142, in143, in144) = (CE::<CI<142>> {}, CE::<CI<143>> {}, CE::<CI<144>> {});
    let (in145, in146, in147) = (CE::<CI<145>> {}, CE::<CI<146>> {}, CE::<CI<147>> {});
    let (in148, in149, in150) = (CE::<CI<148>> {}, CE::<CI<149>> {}, CE::<CI<150>> {});
    let (in151, in152, in153) = (CE::<CI<151>> {}, CE::<CI<152>> {}, CE::<CI<153>> {});
    let (in154, in155, in156) = (CE::<CI<154>> {}, CE::<CI<155>> {}, CE::<CI<156>> {});
    let (in157, in158, in159) = (CE::<CI<157>> {}, CE::<CI<158>> {}, CE::<CI<159>> {});
    let (in160, in161, in162) = (CE::<CI<160>> {}, CE::<CI<161>> {}, CE::<CI<162>> {});
    let (in163, in164, in165) = (CE::<CI<163>> {}, CE::<CI<164>> {}, CE::<CI<165>> {});
    let (in166, in167, in168) = (CE::<CI<166>> {}, CE::<CI<167>> {}, CE::<CI<168>> {});
    let (in169, in170, in171) = (CE::<CI<169>> {}, CE::<CI<170>> {}, CE::<CI<171>> {});
    let (in172, in173, in174) = (CE::<CI<172>> {}, CE::<CI<173>> {}, CE::<CI<174>> {});
    let (in175, in176, in177) = (CE::<CI<175>> {}, CE::<CI<176>> {}, CE::<CI<177>> {});
    let (in178, in179, in180) = (CE::<CI<178>> {}, CE::<CI<179>> {}, CE::<CI<180>> {});
    let (in181, in182, in183) = (CE::<CI<181>> {}, CE::<CI<182>> {}, CE::<CI<183>> {});
    let (in184, in185, in186) = (CE::<CI<184>> {}, CE::<CI<185>> {}, CE::<CI<186>> {});
    let (in187, in188, in189) = (CE::<CI<187>> {}, CE::<CI<188>> {}, CE::<CI<189>> {});
    let (in190, in191, in192) = (CE::<CI<190>> {}, CE::<CI<191>> {}, CE::<CI<192>> {});
    let (in193, in194, in195) = (CE::<CI<193>> {}, CE::<CI<194>> {}, CE::<CI<195>> {});
    let (in196, in197, in198) = (CE::<CI<196>> {}, CE::<CI<197>> {}, CE::<CI<198>> {});
    let (in199, in200, in201) = (CE::<CI<199>> {}, CE::<CI<200>> {}, CE::<CI<201>> {});
    let (in202, in203, in204) = (CE::<CI<202>> {}, CE::<CI<203>> {}, CE::<CI<204>> {});
    let (in205, in206, in207) = (CE::<CI<205>> {}, CE::<CI<206>> {}, CE::<CI<207>> {});
    let (in208, in209, in210) = (CE::<CI<208>> {}, CE::<CI<209>> {}, CE::<CI<210>> {});
    let (in211, in212, in213) = (CE::<CI<211>> {}, CE::<CI<212>> {}, CE::<CI<213>> {});
    let (in214, in215, in216) = (CE::<CI<214>> {}, CE::<CI<215>> {}, CE::<CI<216>> {});
    let (in217, in218, in219) = (CE::<CI<217>> {}, CE::<CI<218>> {}, CE::<CI<219>> {});
    let (in220, in221, in222) = (CE::<CI<220>> {}, CE::<CI<221>> {}, CE::<CI<222>> {});
    let (in223, in224, in225) = (CE::<CI<223>> {}, CE::<CI<224>> {}, CE::<CI<225>> {});
    let (in226, in227, in228) = (CE::<CI<226>> {}, CE::<CI<227>> {}, CE::<CI<228>> {});
    let (in229, in230, in231) = (CE::<CI<229>> {}, CE::<CI<230>> {}, CE::<CI<231>> {});
    let (in232, in233, in234) = (CE::<CI<232>> {}, CE::<CI<233>> {}, CE::<CI<234>> {});
    let (in235, in236, in237) = (CE::<CI<235>> {}, CE::<CI<236>> {}, CE::<CI<237>> {});
    let (in238, in239, in240) = (CE::<CI<238>> {}, CE::<CI<239>> {}, CE::<CI<240>> {});
    let (in241, in242, in243) = (CE::<CI<241>> {}, CE::<CI<242>> {}, CE::<CI<243>> {});
    let (in244, in245, in246) = (CE::<CI<244>> {}, CE::<CI<245>> {}, CE::<CI<246>> {});
    let (in247, in248, in249) = (CE::<CI<247>> {}, CE::<CI<248>> {}, CE::<CI<249>> {});
    let (in250, in251, in252) = (CE::<CI<250>> {}, CE::<CI<251>> {}, CE::<CI<252>> {});
    let (in253, in254, in255) = (CE::<CI<253>> {}, CE::<CI<254>> {}, CE::<CI<255>> {});
    let (in256, in257, in258) = (CE::<CI<256>> {}, CE::<CI<257>> {}, CE::<CI<258>> {});
    let (in259, in260, in261) = (CE::<CI<259>> {}, CE::<CI<260>> {}, CE::<CI<261>> {});
    let (in262, in263, in264) = (CE::<CI<262>> {}, CE::<CI<263>> {}, CE::<CI<264>> {});
    let (in265, in266, in267) = (CE::<CI<265>> {}, CE::<CI<266>> {}, CE::<CI<267>> {});
    let (in268, in269, in270) = (CE::<CI<268>> {}, CE::<CI<269>> {}, CE::<CI<270>> {});
    let (in271, in272, in273) = (CE::<CI<271>> {}, CE::<CI<272>> {}, CE::<CI<273>> {});
    let (in274, in275, in276) = (CE::<CI<274>> {}, CE::<CI<275>> {}, CE::<CI<276>> {});
    let (in277, in278, in279) = (CE::<CI<277>> {}, CE::<CI<278>> {}, CE::<CI<279>> {});
    let (in280, in281, in282) = (CE::<CI<280>> {}, CE::<CI<281>> {}, CE::<CI<282>> {});
    let (in283, in284, in285) = (CE::<CI<283>> {}, CE::<CI<284>> {}, CE::<CI<285>> {});
    let in286 = CE::<CI<286>> {};
    let t0 = circuit_add(in1, in47);
    let t1 = circuit_mul(in258, t0);
    let t2 = circuit_add(in259, t1);
    let t3 = circuit_add(in47, in0);
    let t4 = circuit_mul(in258, t3);
    let t5 = circuit_sub(in259, t4);
    let t6 = circuit_add(t2, in25);
    let t7 = circuit_mul(in0, t6);
    let t8 = circuit_add(t5, in25);
    let t9 = circuit_mul(in0, t8);
    let t10 = circuit_add(t2, in258);
    let t11 = circuit_sub(t5, in258);
    let t12 = circuit_add(t10, in26);
    let t13 = circuit_mul(t7, t12);
    let t14 = circuit_add(t11, in26);
    let t15 = circuit_mul(t9, t14);
    let t16 = circuit_add(t10, in258);
    let t17 = circuit_sub(t11, in258);
    let t18 = circuit_add(t16, in27);
    let t19 = circuit_mul(t13, t18);
    let t20 = circuit_add(t17, in27);
    let t21 = circuit_mul(t15, t20);
    let t22 = circuit_add(t16, in258);
    let t23 = circuit_sub(t17, in258);
    let t24 = circuit_add(t22, in28);
    let t25 = circuit_mul(t19, t24);
    let t26 = circuit_add(t23, in28);
    let t27 = circuit_mul(t21, t26);
    let t28 = circuit_add(t22, in258);
    let t29 = circuit_sub(t23, in258);
    let t30 = circuit_add(t28, in29);
    let t31 = circuit_mul(t25, t30);
    let t32 = circuit_add(t29, in29);
    let t33 = circuit_mul(t27, t32);
    let t34 = circuit_add(t28, in258);
    let t35 = circuit_sub(t29, in258);
    let t36 = circuit_add(t34, in30);
    let t37 = circuit_mul(t31, t36);
    let t38 = circuit_add(t35, in30);
    let t39 = circuit_mul(t33, t38);
    let t40 = circuit_add(t34, in258);
    let t41 = circuit_sub(t35, in258);
    let t42 = circuit_add(t40, in31);
    let t43 = circuit_mul(t37, t42);
    let t44 = circuit_add(t41, in31);
    let t45 = circuit_mul(t39, t44);
    let t46 = circuit_add(t40, in258);
    let t47 = circuit_sub(t41, in258);
    let t48 = circuit_add(t46, in32);
    let t49 = circuit_mul(t43, t48);
    let t50 = circuit_add(t47, in32);
    let t51 = circuit_mul(t45, t50);
    let t52 = circuit_add(t46, in258);
    let t53 = circuit_sub(t47, in258);
    let t54 = circuit_add(t52, in33);
    let t55 = circuit_mul(t49, t54);
    let t56 = circuit_add(t53, in33);
    let t57 = circuit_mul(t51, t56);
    let t58 = circuit_add(t52, in258);
    let t59 = circuit_sub(t53, in258);
    let t60 = circuit_add(t58, in34);
    let t61 = circuit_mul(t55, t60);
    let t62 = circuit_add(t59, in34);
    let t63 = circuit_mul(t57, t62);
    let t64 = circuit_add(t58, in258);
    let t65 = circuit_sub(t59, in258);
    let t66 = circuit_add(t64, in35);
    let t67 = circuit_mul(t61, t66);
    let t68 = circuit_add(t65, in35);
    let t69 = circuit_mul(t63, t68);
    let t70 = circuit_add(t64, in258);
    let t71 = circuit_sub(t65, in258);
    let t72 = circuit_add(t70, in36);
    let t73 = circuit_mul(t67, t72);
    let t74 = circuit_add(t71, in36);
    let t75 = circuit_mul(t69, t74);
    let t76 = circuit_add(t70, in258);
    let t77 = circuit_sub(t71, in258);
    let t78 = circuit_add(t76, in37);
    let t79 = circuit_mul(t73, t78);
    let t80 = circuit_add(t77, in37);
    let t81 = circuit_mul(t75, t80);
    let t82 = circuit_add(t76, in258);
    let t83 = circuit_sub(t77, in258);
    let t84 = circuit_add(t82, in38);
    let t85 = circuit_mul(t79, t84);
    let t86 = circuit_add(t83, in38);
    let t87 = circuit_mul(t81, t86);
    let t88 = circuit_add(t82, in258);
    let t89 = circuit_sub(t83, in258);
    let t90 = circuit_add(t88, in39);
    let t91 = circuit_mul(t85, t90);
    let t92 = circuit_add(t89, in39);
    let t93 = circuit_mul(t87, t92);
    let t94 = circuit_add(t88, in258);
    let t95 = circuit_sub(t89, in258);
    let t96 = circuit_add(t94, in40);
    let t97 = circuit_mul(t91, t96);
    let t98 = circuit_add(t95, in40);
    let t99 = circuit_mul(t93, t98);
    let t100 = circuit_add(t94, in258);
    let t101 = circuit_sub(t95, in258);
    let t102 = circuit_add(t100, in41);
    let t103 = circuit_mul(t97, t102);
    let t104 = circuit_add(t101, in41);
    let t105 = circuit_mul(t99, t104);
    let t106 = circuit_add(t100, in258);
    let t107 = circuit_sub(t101, in258);
    let t108 = circuit_add(t106, in42);
    let t109 = circuit_mul(t103, t108);
    let t110 = circuit_add(t107, in42);
    let t111 = circuit_mul(t105, t110);
    let t112 = circuit_add(t106, in258);
    let t113 = circuit_sub(t107, in258);
    let t114 = circuit_add(t112, in43);
    let t115 = circuit_mul(t109, t114);
    let t116 = circuit_add(t113, in43);
    let t117 = circuit_mul(t111, t116);
    let t118 = circuit_add(t112, in258);
    let t119 = circuit_sub(t113, in258);
    let t120 = circuit_add(t118, in44);
    let t121 = circuit_mul(t115, t120);
    let t122 = circuit_add(t119, in44);
    let t123 = circuit_mul(t117, t122);
    let t124 = circuit_add(t118, in258);
    let t125 = circuit_sub(t119, in258);
    let t126 = circuit_add(t124, in45);
    let t127 = circuit_mul(t121, t126);
    let t128 = circuit_add(t125, in45);
    let t129 = circuit_mul(t123, t128);
    let t130 = circuit_add(t124, in258);
    let t131 = circuit_sub(t125, in258);
    let t132 = circuit_add(t130, in46);
    let t133 = circuit_mul(t127, t132);
    let t134 = circuit_add(t131, in46);
    let t135 = circuit_mul(t129, t134);
    let t136 = circuit_inverse(t135);
    let t137 = circuit_mul(t133, t136);
    let t138 = circuit_mul(in286, in48);
    let t139 = circuit_add(in49, in50);
    let t140 = circuit_sub(t139, t138);
    let t141 = circuit_mul(t140, in260);
    let t142 = circuit_mul(in260, in260);
    let t143 = circuit_sub(in225, in7);
    let t144 = circuit_mul(in0, t143);
    let t145 = circuit_sub(in225, in7);
    let t146 = circuit_mul(in2, t145);
    let t147 = circuit_inverse(t146);
    let t148 = circuit_mul(in49, t147);
    let t149 = circuit_add(in7, t148);
    let t150 = circuit_sub(in225, in0);
    let t151 = circuit_mul(t144, t150);
    let t152 = circuit_sub(in225, in0);
    let t153 = circuit_mul(in3, t152);
    let t154 = circuit_inverse(t153);
    let t155 = circuit_mul(in50, t154);
    let t156 = circuit_add(t149, t155);
    let t157 = circuit_sub(in225, in8);
    let t158 = circuit_mul(t151, t157);
    let t159 = circuit_sub(in225, in8);
    let t160 = circuit_mul(in4, t159);
    let t161 = circuit_inverse(t160);
    let t162 = circuit_mul(in51, t161);
    let t163 = circuit_add(t156, t162);
    let t164 = circuit_sub(in225, in9);
    let t165 = circuit_mul(t158, t164);
    let t166 = circuit_sub(in225, in9);
    let t167 = circuit_mul(in5, t166);
    let t168 = circuit_inverse(t167);
    let t169 = circuit_mul(in52, t168);
    let t170 = circuit_add(t163, t169);
    let t171 = circuit_sub(in225, in10);
    let t172 = circuit_mul(t165, t171);
    let t173 = circuit_sub(in225, in10);
    let t174 = circuit_mul(in6, t173);
    let t175 = circuit_inverse(t174);
    let t176 = circuit_mul(in53, t175);
    let t177 = circuit_add(t170, t176);
    let t178 = circuit_sub(in225, in11);
    let t179 = circuit_mul(t172, t178);
    let t180 = circuit_sub(in225, in11);
    let t181 = circuit_mul(in5, t180);
    let t182 = circuit_inverse(t181);
    let t183 = circuit_mul(in54, t182);
    let t184 = circuit_add(t177, t183);
    let t185 = circuit_sub(in225, in12);
    let t186 = circuit_mul(t179, t185);
    let t187 = circuit_sub(in225, in12);
    let t188 = circuit_mul(in4, t187);
    let t189 = circuit_inverse(t188);
    let t190 = circuit_mul(in55, t189);
    let t191 = circuit_add(t184, t190);
    let t192 = circuit_sub(in225, in13);
    let t193 = circuit_mul(t186, t192);
    let t194 = circuit_sub(in225, in13);
    let t195 = circuit_mul(in3, t194);
    let t196 = circuit_inverse(t195);
    let t197 = circuit_mul(in56, t196);
    let t198 = circuit_add(t191, t197);
    let t199 = circuit_sub(in225, in14);
    let t200 = circuit_mul(t193, t199);
    let t201 = circuit_sub(in225, in14);
    let t202 = circuit_mul(in2, t201);
    let t203 = circuit_inverse(t202);
    let t204 = circuit_mul(in57, t203);
    let t205 = circuit_add(t198, t204);
    let t206 = circuit_mul(t205, t200);
    let t207 = circuit_sub(in240, in0);
    let t208 = circuit_mul(in225, t207);
    let t209 = circuit_add(in0, t208);
    let t210 = circuit_mul(in0, t209);
    let t211 = circuit_add(in58, in59);
    let t212 = circuit_sub(t211, t206);
    let t213 = circuit_mul(t212, t142);
    let t214 = circuit_add(t141, t213);
    let t215 = circuit_mul(t142, in260);
    let t216 = circuit_sub(in226, in7);
    let t217 = circuit_mul(in0, t216);
    let t218 = circuit_sub(in226, in7);
    let t219 = circuit_mul(in2, t218);
    let t220 = circuit_inverse(t219);
    let t221 = circuit_mul(in58, t220);
    let t222 = circuit_add(in7, t221);
    let t223 = circuit_sub(in226, in0);
    let t224 = circuit_mul(t217, t223);
    let t225 = circuit_sub(in226, in0);
    let t226 = circuit_mul(in3, t225);
    let t227 = circuit_inverse(t226);
    let t228 = circuit_mul(in59, t227);
    let t229 = circuit_add(t222, t228);
    let t230 = circuit_sub(in226, in8);
    let t231 = circuit_mul(t224, t230);
    let t232 = circuit_sub(in226, in8);
    let t233 = circuit_mul(in4, t232);
    let t234 = circuit_inverse(t233);
    let t235 = circuit_mul(in60, t234);
    let t236 = circuit_add(t229, t235);
    let t237 = circuit_sub(in226, in9);
    let t238 = circuit_mul(t231, t237);
    let t239 = circuit_sub(in226, in9);
    let t240 = circuit_mul(in5, t239);
    let t241 = circuit_inverse(t240);
    let t242 = circuit_mul(in61, t241);
    let t243 = circuit_add(t236, t242);
    let t244 = circuit_sub(in226, in10);
    let t245 = circuit_mul(t238, t244);
    let t246 = circuit_sub(in226, in10);
    let t247 = circuit_mul(in6, t246);
    let t248 = circuit_inverse(t247);
    let t249 = circuit_mul(in62, t248);
    let t250 = circuit_add(t243, t249);
    let t251 = circuit_sub(in226, in11);
    let t252 = circuit_mul(t245, t251);
    let t253 = circuit_sub(in226, in11);
    let t254 = circuit_mul(in5, t253);
    let t255 = circuit_inverse(t254);
    let t256 = circuit_mul(in63, t255);
    let t257 = circuit_add(t250, t256);
    let t258 = circuit_sub(in226, in12);
    let t259 = circuit_mul(t252, t258);
    let t260 = circuit_sub(in226, in12);
    let t261 = circuit_mul(in4, t260);
    let t262 = circuit_inverse(t261);
    let t263 = circuit_mul(in64, t262);
    let t264 = circuit_add(t257, t263);
    let t265 = circuit_sub(in226, in13);
    let t266 = circuit_mul(t259, t265);
    let t267 = circuit_sub(in226, in13);
    let t268 = circuit_mul(in3, t267);
    let t269 = circuit_inverse(t268);
    let t270 = circuit_mul(in65, t269);
    let t271 = circuit_add(t264, t270);
    let t272 = circuit_sub(in226, in14);
    let t273 = circuit_mul(t266, t272);
    let t274 = circuit_sub(in226, in14);
    let t275 = circuit_mul(in2, t274);
    let t276 = circuit_inverse(t275);
    let t277 = circuit_mul(in66, t276);
    let t278 = circuit_add(t271, t277);
    let t279 = circuit_mul(t278, t273);
    let t280 = circuit_sub(in241, in0);
    let t281 = circuit_mul(in226, t280);
    let t282 = circuit_add(in0, t281);
    let t283 = circuit_mul(t210, t282);
    let t284 = circuit_add(in67, in68);
    let t285 = circuit_sub(t284, t279);
    let t286 = circuit_mul(t285, t215);
    let t287 = circuit_add(t214, t286);
    let t288 = circuit_mul(t215, in260);
    let t289 = circuit_sub(in227, in7);
    let t290 = circuit_mul(in0, t289);
    let t291 = circuit_sub(in227, in7);
    let t292 = circuit_mul(in2, t291);
    let t293 = circuit_inverse(t292);
    let t294 = circuit_mul(in67, t293);
    let t295 = circuit_add(in7, t294);
    let t296 = circuit_sub(in227, in0);
    let t297 = circuit_mul(t290, t296);
    let t298 = circuit_sub(in227, in0);
    let t299 = circuit_mul(in3, t298);
    let t300 = circuit_inverse(t299);
    let t301 = circuit_mul(in68, t300);
    let t302 = circuit_add(t295, t301);
    let t303 = circuit_sub(in227, in8);
    let t304 = circuit_mul(t297, t303);
    let t305 = circuit_sub(in227, in8);
    let t306 = circuit_mul(in4, t305);
    let t307 = circuit_inverse(t306);
    let t308 = circuit_mul(in69, t307);
    let t309 = circuit_add(t302, t308);
    let t310 = circuit_sub(in227, in9);
    let t311 = circuit_mul(t304, t310);
    let t312 = circuit_sub(in227, in9);
    let t313 = circuit_mul(in5, t312);
    let t314 = circuit_inverse(t313);
    let t315 = circuit_mul(in70, t314);
    let t316 = circuit_add(t309, t315);
    let t317 = circuit_sub(in227, in10);
    let t318 = circuit_mul(t311, t317);
    let t319 = circuit_sub(in227, in10);
    let t320 = circuit_mul(in6, t319);
    let t321 = circuit_inverse(t320);
    let t322 = circuit_mul(in71, t321);
    let t323 = circuit_add(t316, t322);
    let t324 = circuit_sub(in227, in11);
    let t325 = circuit_mul(t318, t324);
    let t326 = circuit_sub(in227, in11);
    let t327 = circuit_mul(in5, t326);
    let t328 = circuit_inverse(t327);
    let t329 = circuit_mul(in72, t328);
    let t330 = circuit_add(t323, t329);
    let t331 = circuit_sub(in227, in12);
    let t332 = circuit_mul(t325, t331);
    let t333 = circuit_sub(in227, in12);
    let t334 = circuit_mul(in4, t333);
    let t335 = circuit_inverse(t334);
    let t336 = circuit_mul(in73, t335);
    let t337 = circuit_add(t330, t336);
    let t338 = circuit_sub(in227, in13);
    let t339 = circuit_mul(t332, t338);
    let t340 = circuit_sub(in227, in13);
    let t341 = circuit_mul(in3, t340);
    let t342 = circuit_inverse(t341);
    let t343 = circuit_mul(in74, t342);
    let t344 = circuit_add(t337, t343);
    let t345 = circuit_sub(in227, in14);
    let t346 = circuit_mul(t339, t345);
    let t347 = circuit_sub(in227, in14);
    let t348 = circuit_mul(in2, t347);
    let t349 = circuit_inverse(t348);
    let t350 = circuit_mul(in75, t349);
    let t351 = circuit_add(t344, t350);
    let t352 = circuit_mul(t351, t346);
    let t353 = circuit_sub(in242, in0);
    let t354 = circuit_mul(in227, t353);
    let t355 = circuit_add(in0, t354);
    let t356 = circuit_mul(t283, t355);
    let t357 = circuit_add(in76, in77);
    let t358 = circuit_sub(t357, t352);
    let t359 = circuit_mul(t358, t288);
    let t360 = circuit_add(t287, t359);
    let t361 = circuit_mul(t288, in260);
    let t362 = circuit_sub(in228, in7);
    let t363 = circuit_mul(in0, t362);
    let t364 = circuit_sub(in228, in7);
    let t365 = circuit_mul(in2, t364);
    let t366 = circuit_inverse(t365);
    let t367 = circuit_mul(in76, t366);
    let t368 = circuit_add(in7, t367);
    let t369 = circuit_sub(in228, in0);
    let t370 = circuit_mul(t363, t369);
    let t371 = circuit_sub(in228, in0);
    let t372 = circuit_mul(in3, t371);
    let t373 = circuit_inverse(t372);
    let t374 = circuit_mul(in77, t373);
    let t375 = circuit_add(t368, t374);
    let t376 = circuit_sub(in228, in8);
    let t377 = circuit_mul(t370, t376);
    let t378 = circuit_sub(in228, in8);
    let t379 = circuit_mul(in4, t378);
    let t380 = circuit_inverse(t379);
    let t381 = circuit_mul(in78, t380);
    let t382 = circuit_add(t375, t381);
    let t383 = circuit_sub(in228, in9);
    let t384 = circuit_mul(t377, t383);
    let t385 = circuit_sub(in228, in9);
    let t386 = circuit_mul(in5, t385);
    let t387 = circuit_inverse(t386);
    let t388 = circuit_mul(in79, t387);
    let t389 = circuit_add(t382, t388);
    let t390 = circuit_sub(in228, in10);
    let t391 = circuit_mul(t384, t390);
    let t392 = circuit_sub(in228, in10);
    let t393 = circuit_mul(in6, t392);
    let t394 = circuit_inverse(t393);
    let t395 = circuit_mul(in80, t394);
    let t396 = circuit_add(t389, t395);
    let t397 = circuit_sub(in228, in11);
    let t398 = circuit_mul(t391, t397);
    let t399 = circuit_sub(in228, in11);
    let t400 = circuit_mul(in5, t399);
    let t401 = circuit_inverse(t400);
    let t402 = circuit_mul(in81, t401);
    let t403 = circuit_add(t396, t402);
    let t404 = circuit_sub(in228, in12);
    let t405 = circuit_mul(t398, t404);
    let t406 = circuit_sub(in228, in12);
    let t407 = circuit_mul(in4, t406);
    let t408 = circuit_inverse(t407);
    let t409 = circuit_mul(in82, t408);
    let t410 = circuit_add(t403, t409);
    let t411 = circuit_sub(in228, in13);
    let t412 = circuit_mul(t405, t411);
    let t413 = circuit_sub(in228, in13);
    let t414 = circuit_mul(in3, t413);
    let t415 = circuit_inverse(t414);
    let t416 = circuit_mul(in83, t415);
    let t417 = circuit_add(t410, t416);
    let t418 = circuit_sub(in228, in14);
    let t419 = circuit_mul(t412, t418);
    let t420 = circuit_sub(in228, in14);
    let t421 = circuit_mul(in2, t420);
    let t422 = circuit_inverse(t421);
    let t423 = circuit_mul(in84, t422);
    let t424 = circuit_add(t417, t423);
    let t425 = circuit_mul(t424, t419);
    let t426 = circuit_sub(in243, in0);
    let t427 = circuit_mul(in228, t426);
    let t428 = circuit_add(in0, t427);
    let t429 = circuit_mul(t356, t428);
    let t430 = circuit_add(in85, in86);
    let t431 = circuit_sub(t430, t425);
    let t432 = circuit_mul(t431, t361);
    let t433 = circuit_add(t360, t432);
    let t434 = circuit_mul(t361, in260);
    let t435 = circuit_sub(in229, in7);
    let t436 = circuit_mul(in0, t435);
    let t437 = circuit_sub(in229, in7);
    let t438 = circuit_mul(in2, t437);
    let t439 = circuit_inverse(t438);
    let t440 = circuit_mul(in85, t439);
    let t441 = circuit_add(in7, t440);
    let t442 = circuit_sub(in229, in0);
    let t443 = circuit_mul(t436, t442);
    let t444 = circuit_sub(in229, in0);
    let t445 = circuit_mul(in3, t444);
    let t446 = circuit_inverse(t445);
    let t447 = circuit_mul(in86, t446);
    let t448 = circuit_add(t441, t447);
    let t449 = circuit_sub(in229, in8);
    let t450 = circuit_mul(t443, t449);
    let t451 = circuit_sub(in229, in8);
    let t452 = circuit_mul(in4, t451);
    let t453 = circuit_inverse(t452);
    let t454 = circuit_mul(in87, t453);
    let t455 = circuit_add(t448, t454);
    let t456 = circuit_sub(in229, in9);
    let t457 = circuit_mul(t450, t456);
    let t458 = circuit_sub(in229, in9);
    let t459 = circuit_mul(in5, t458);
    let t460 = circuit_inverse(t459);
    let t461 = circuit_mul(in88, t460);
    let t462 = circuit_add(t455, t461);
    let t463 = circuit_sub(in229, in10);
    let t464 = circuit_mul(t457, t463);
    let t465 = circuit_sub(in229, in10);
    let t466 = circuit_mul(in6, t465);
    let t467 = circuit_inverse(t466);
    let t468 = circuit_mul(in89, t467);
    let t469 = circuit_add(t462, t468);
    let t470 = circuit_sub(in229, in11);
    let t471 = circuit_mul(t464, t470);
    let t472 = circuit_sub(in229, in11);
    let t473 = circuit_mul(in5, t472);
    let t474 = circuit_inverse(t473);
    let t475 = circuit_mul(in90, t474);
    let t476 = circuit_add(t469, t475);
    let t477 = circuit_sub(in229, in12);
    let t478 = circuit_mul(t471, t477);
    let t479 = circuit_sub(in229, in12);
    let t480 = circuit_mul(in4, t479);
    let t481 = circuit_inverse(t480);
    let t482 = circuit_mul(in91, t481);
    let t483 = circuit_add(t476, t482);
    let t484 = circuit_sub(in229, in13);
    let t485 = circuit_mul(t478, t484);
    let t486 = circuit_sub(in229, in13);
    let t487 = circuit_mul(in3, t486);
    let t488 = circuit_inverse(t487);
    let t489 = circuit_mul(in92, t488);
    let t490 = circuit_add(t483, t489);
    let t491 = circuit_sub(in229, in14);
    let t492 = circuit_mul(t485, t491);
    let t493 = circuit_sub(in229, in14);
    let t494 = circuit_mul(in2, t493);
    let t495 = circuit_inverse(t494);
    let t496 = circuit_mul(in93, t495);
    let t497 = circuit_add(t490, t496);
    let t498 = circuit_mul(t497, t492);
    let t499 = circuit_sub(in244, in0);
    let t500 = circuit_mul(in229, t499);
    let t501 = circuit_add(in0, t500);
    let t502 = circuit_mul(t429, t501);
    let t503 = circuit_add(in94, in95);
    let t504 = circuit_sub(t503, t498);
    let t505 = circuit_mul(t504, t434);
    let t506 = circuit_add(t433, t505);
    let t507 = circuit_mul(t434, in260);
    let t508 = circuit_sub(in230, in7);
    let t509 = circuit_mul(in0, t508);
    let t510 = circuit_sub(in230, in7);
    let t511 = circuit_mul(in2, t510);
    let t512 = circuit_inverse(t511);
    let t513 = circuit_mul(in94, t512);
    let t514 = circuit_add(in7, t513);
    let t515 = circuit_sub(in230, in0);
    let t516 = circuit_mul(t509, t515);
    let t517 = circuit_sub(in230, in0);
    let t518 = circuit_mul(in3, t517);
    let t519 = circuit_inverse(t518);
    let t520 = circuit_mul(in95, t519);
    let t521 = circuit_add(t514, t520);
    let t522 = circuit_sub(in230, in8);
    let t523 = circuit_mul(t516, t522);
    let t524 = circuit_sub(in230, in8);
    let t525 = circuit_mul(in4, t524);
    let t526 = circuit_inverse(t525);
    let t527 = circuit_mul(in96, t526);
    let t528 = circuit_add(t521, t527);
    let t529 = circuit_sub(in230, in9);
    let t530 = circuit_mul(t523, t529);
    let t531 = circuit_sub(in230, in9);
    let t532 = circuit_mul(in5, t531);
    let t533 = circuit_inverse(t532);
    let t534 = circuit_mul(in97, t533);
    let t535 = circuit_add(t528, t534);
    let t536 = circuit_sub(in230, in10);
    let t537 = circuit_mul(t530, t536);
    let t538 = circuit_sub(in230, in10);
    let t539 = circuit_mul(in6, t538);
    let t540 = circuit_inverse(t539);
    let t541 = circuit_mul(in98, t540);
    let t542 = circuit_add(t535, t541);
    let t543 = circuit_sub(in230, in11);
    let t544 = circuit_mul(t537, t543);
    let t545 = circuit_sub(in230, in11);
    let t546 = circuit_mul(in5, t545);
    let t547 = circuit_inverse(t546);
    let t548 = circuit_mul(in99, t547);
    let t549 = circuit_add(t542, t548);
    let t550 = circuit_sub(in230, in12);
    let t551 = circuit_mul(t544, t550);
    let t552 = circuit_sub(in230, in12);
    let t553 = circuit_mul(in4, t552);
    let t554 = circuit_inverse(t553);
    let t555 = circuit_mul(in100, t554);
    let t556 = circuit_add(t549, t555);
    let t557 = circuit_sub(in230, in13);
    let t558 = circuit_mul(t551, t557);
    let t559 = circuit_sub(in230, in13);
    let t560 = circuit_mul(in3, t559);
    let t561 = circuit_inverse(t560);
    let t562 = circuit_mul(in101, t561);
    let t563 = circuit_add(t556, t562);
    let t564 = circuit_sub(in230, in14);
    let t565 = circuit_mul(t558, t564);
    let t566 = circuit_sub(in230, in14);
    let t567 = circuit_mul(in2, t566);
    let t568 = circuit_inverse(t567);
    let t569 = circuit_mul(in102, t568);
    let t570 = circuit_add(t563, t569);
    let t571 = circuit_mul(t570, t565);
    let t572 = circuit_sub(in245, in0);
    let t573 = circuit_mul(in230, t572);
    let t574 = circuit_add(in0, t573);
    let t575 = circuit_mul(t502, t574);
    let t576 = circuit_add(in103, in104);
    let t577 = circuit_sub(t576, t571);
    let t578 = circuit_mul(t577, t507);
    let t579 = circuit_add(t506, t578);
    let t580 = circuit_mul(t507, in260);
    let t581 = circuit_sub(in231, in7);
    let t582 = circuit_mul(in0, t581);
    let t583 = circuit_sub(in231, in7);
    let t584 = circuit_mul(in2, t583);
    let t585 = circuit_inverse(t584);
    let t586 = circuit_mul(in103, t585);
    let t587 = circuit_add(in7, t586);
    let t588 = circuit_sub(in231, in0);
    let t589 = circuit_mul(t582, t588);
    let t590 = circuit_sub(in231, in0);
    let t591 = circuit_mul(in3, t590);
    let t592 = circuit_inverse(t591);
    let t593 = circuit_mul(in104, t592);
    let t594 = circuit_add(t587, t593);
    let t595 = circuit_sub(in231, in8);
    let t596 = circuit_mul(t589, t595);
    let t597 = circuit_sub(in231, in8);
    let t598 = circuit_mul(in4, t597);
    let t599 = circuit_inverse(t598);
    let t600 = circuit_mul(in105, t599);
    let t601 = circuit_add(t594, t600);
    let t602 = circuit_sub(in231, in9);
    let t603 = circuit_mul(t596, t602);
    let t604 = circuit_sub(in231, in9);
    let t605 = circuit_mul(in5, t604);
    let t606 = circuit_inverse(t605);
    let t607 = circuit_mul(in106, t606);
    let t608 = circuit_add(t601, t607);
    let t609 = circuit_sub(in231, in10);
    let t610 = circuit_mul(t603, t609);
    let t611 = circuit_sub(in231, in10);
    let t612 = circuit_mul(in6, t611);
    let t613 = circuit_inverse(t612);
    let t614 = circuit_mul(in107, t613);
    let t615 = circuit_add(t608, t614);
    let t616 = circuit_sub(in231, in11);
    let t617 = circuit_mul(t610, t616);
    let t618 = circuit_sub(in231, in11);
    let t619 = circuit_mul(in5, t618);
    let t620 = circuit_inverse(t619);
    let t621 = circuit_mul(in108, t620);
    let t622 = circuit_add(t615, t621);
    let t623 = circuit_sub(in231, in12);
    let t624 = circuit_mul(t617, t623);
    let t625 = circuit_sub(in231, in12);
    let t626 = circuit_mul(in4, t625);
    let t627 = circuit_inverse(t626);
    let t628 = circuit_mul(in109, t627);
    let t629 = circuit_add(t622, t628);
    let t630 = circuit_sub(in231, in13);
    let t631 = circuit_mul(t624, t630);
    let t632 = circuit_sub(in231, in13);
    let t633 = circuit_mul(in3, t632);
    let t634 = circuit_inverse(t633);
    let t635 = circuit_mul(in110, t634);
    let t636 = circuit_add(t629, t635);
    let t637 = circuit_sub(in231, in14);
    let t638 = circuit_mul(t631, t637);
    let t639 = circuit_sub(in231, in14);
    let t640 = circuit_mul(in2, t639);
    let t641 = circuit_inverse(t640);
    let t642 = circuit_mul(in111, t641);
    let t643 = circuit_add(t636, t642);
    let t644 = circuit_mul(t643, t638);
    let t645 = circuit_sub(in246, in0);
    let t646 = circuit_mul(in231, t645);
    let t647 = circuit_add(in0, t646);
    let t648 = circuit_mul(t575, t647);
    let t649 = circuit_add(in112, in113);
    let t650 = circuit_sub(t649, t644);
    let t651 = circuit_mul(t650, t580);
    let t652 = circuit_add(t579, t651);
    let t653 = circuit_mul(t580, in260);
    let t654 = circuit_sub(in232, in7);
    let t655 = circuit_mul(in0, t654);
    let t656 = circuit_sub(in232, in7);
    let t657 = circuit_mul(in2, t656);
    let t658 = circuit_inverse(t657);
    let t659 = circuit_mul(in112, t658);
    let t660 = circuit_add(in7, t659);
    let t661 = circuit_sub(in232, in0);
    let t662 = circuit_mul(t655, t661);
    let t663 = circuit_sub(in232, in0);
    let t664 = circuit_mul(in3, t663);
    let t665 = circuit_inverse(t664);
    let t666 = circuit_mul(in113, t665);
    let t667 = circuit_add(t660, t666);
    let t668 = circuit_sub(in232, in8);
    let t669 = circuit_mul(t662, t668);
    let t670 = circuit_sub(in232, in8);
    let t671 = circuit_mul(in4, t670);
    let t672 = circuit_inverse(t671);
    let t673 = circuit_mul(in114, t672);
    let t674 = circuit_add(t667, t673);
    let t675 = circuit_sub(in232, in9);
    let t676 = circuit_mul(t669, t675);
    let t677 = circuit_sub(in232, in9);
    let t678 = circuit_mul(in5, t677);
    let t679 = circuit_inverse(t678);
    let t680 = circuit_mul(in115, t679);
    let t681 = circuit_add(t674, t680);
    let t682 = circuit_sub(in232, in10);
    let t683 = circuit_mul(t676, t682);
    let t684 = circuit_sub(in232, in10);
    let t685 = circuit_mul(in6, t684);
    let t686 = circuit_inverse(t685);
    let t687 = circuit_mul(in116, t686);
    let t688 = circuit_add(t681, t687);
    let t689 = circuit_sub(in232, in11);
    let t690 = circuit_mul(t683, t689);
    let t691 = circuit_sub(in232, in11);
    let t692 = circuit_mul(in5, t691);
    let t693 = circuit_inverse(t692);
    let t694 = circuit_mul(in117, t693);
    let t695 = circuit_add(t688, t694);
    let t696 = circuit_sub(in232, in12);
    let t697 = circuit_mul(t690, t696);
    let t698 = circuit_sub(in232, in12);
    let t699 = circuit_mul(in4, t698);
    let t700 = circuit_inverse(t699);
    let t701 = circuit_mul(in118, t700);
    let t702 = circuit_add(t695, t701);
    let t703 = circuit_sub(in232, in13);
    let t704 = circuit_mul(t697, t703);
    let t705 = circuit_sub(in232, in13);
    let t706 = circuit_mul(in3, t705);
    let t707 = circuit_inverse(t706);
    let t708 = circuit_mul(in119, t707);
    let t709 = circuit_add(t702, t708);
    let t710 = circuit_sub(in232, in14);
    let t711 = circuit_mul(t704, t710);
    let t712 = circuit_sub(in232, in14);
    let t713 = circuit_mul(in2, t712);
    let t714 = circuit_inverse(t713);
    let t715 = circuit_mul(in120, t714);
    let t716 = circuit_add(t709, t715);
    let t717 = circuit_mul(t716, t711);
    let t718 = circuit_sub(in247, in0);
    let t719 = circuit_mul(in232, t718);
    let t720 = circuit_add(in0, t719);
    let t721 = circuit_mul(t648, t720);
    let t722 = circuit_add(in121, in122);
    let t723 = circuit_sub(t722, t717);
    let t724 = circuit_mul(t723, t653);
    let t725 = circuit_add(t652, t724);
    let t726 = circuit_mul(t653, in260);
    let t727 = circuit_sub(in233, in7);
    let t728 = circuit_mul(in0, t727);
    let t729 = circuit_sub(in233, in7);
    let t730 = circuit_mul(in2, t729);
    let t731 = circuit_inverse(t730);
    let t732 = circuit_mul(in121, t731);
    let t733 = circuit_add(in7, t732);
    let t734 = circuit_sub(in233, in0);
    let t735 = circuit_mul(t728, t734);
    let t736 = circuit_sub(in233, in0);
    let t737 = circuit_mul(in3, t736);
    let t738 = circuit_inverse(t737);
    let t739 = circuit_mul(in122, t738);
    let t740 = circuit_add(t733, t739);
    let t741 = circuit_sub(in233, in8);
    let t742 = circuit_mul(t735, t741);
    let t743 = circuit_sub(in233, in8);
    let t744 = circuit_mul(in4, t743);
    let t745 = circuit_inverse(t744);
    let t746 = circuit_mul(in123, t745);
    let t747 = circuit_add(t740, t746);
    let t748 = circuit_sub(in233, in9);
    let t749 = circuit_mul(t742, t748);
    let t750 = circuit_sub(in233, in9);
    let t751 = circuit_mul(in5, t750);
    let t752 = circuit_inverse(t751);
    let t753 = circuit_mul(in124, t752);
    let t754 = circuit_add(t747, t753);
    let t755 = circuit_sub(in233, in10);
    let t756 = circuit_mul(t749, t755);
    let t757 = circuit_sub(in233, in10);
    let t758 = circuit_mul(in6, t757);
    let t759 = circuit_inverse(t758);
    let t760 = circuit_mul(in125, t759);
    let t761 = circuit_add(t754, t760);
    let t762 = circuit_sub(in233, in11);
    let t763 = circuit_mul(t756, t762);
    let t764 = circuit_sub(in233, in11);
    let t765 = circuit_mul(in5, t764);
    let t766 = circuit_inverse(t765);
    let t767 = circuit_mul(in126, t766);
    let t768 = circuit_add(t761, t767);
    let t769 = circuit_sub(in233, in12);
    let t770 = circuit_mul(t763, t769);
    let t771 = circuit_sub(in233, in12);
    let t772 = circuit_mul(in4, t771);
    let t773 = circuit_inverse(t772);
    let t774 = circuit_mul(in127, t773);
    let t775 = circuit_add(t768, t774);
    let t776 = circuit_sub(in233, in13);
    let t777 = circuit_mul(t770, t776);
    let t778 = circuit_sub(in233, in13);
    let t779 = circuit_mul(in3, t778);
    let t780 = circuit_inverse(t779);
    let t781 = circuit_mul(in128, t780);
    let t782 = circuit_add(t775, t781);
    let t783 = circuit_sub(in233, in14);
    let t784 = circuit_mul(t777, t783);
    let t785 = circuit_sub(in233, in14);
    let t786 = circuit_mul(in2, t785);
    let t787 = circuit_inverse(t786);
    let t788 = circuit_mul(in129, t787);
    let t789 = circuit_add(t782, t788);
    let t790 = circuit_mul(t789, t784);
    let t791 = circuit_sub(in248, in0);
    let t792 = circuit_mul(in233, t791);
    let t793 = circuit_add(in0, t792);
    let t794 = circuit_mul(t721, t793);
    let t795 = circuit_add(in130, in131);
    let t796 = circuit_sub(t795, t790);
    let t797 = circuit_mul(t796, t726);
    let t798 = circuit_add(t725, t797);
    let t799 = circuit_mul(t726, in260);
    let t800 = circuit_sub(in234, in7);
    let t801 = circuit_mul(in0, t800);
    let t802 = circuit_sub(in234, in7);
    let t803 = circuit_mul(in2, t802);
    let t804 = circuit_inverse(t803);
    let t805 = circuit_mul(in130, t804);
    let t806 = circuit_add(in7, t805);
    let t807 = circuit_sub(in234, in0);
    let t808 = circuit_mul(t801, t807);
    let t809 = circuit_sub(in234, in0);
    let t810 = circuit_mul(in3, t809);
    let t811 = circuit_inverse(t810);
    let t812 = circuit_mul(in131, t811);
    let t813 = circuit_add(t806, t812);
    let t814 = circuit_sub(in234, in8);
    let t815 = circuit_mul(t808, t814);
    let t816 = circuit_sub(in234, in8);
    let t817 = circuit_mul(in4, t816);
    let t818 = circuit_inverse(t817);
    let t819 = circuit_mul(in132, t818);
    let t820 = circuit_add(t813, t819);
    let t821 = circuit_sub(in234, in9);
    let t822 = circuit_mul(t815, t821);
    let t823 = circuit_sub(in234, in9);
    let t824 = circuit_mul(in5, t823);
    let t825 = circuit_inverse(t824);
    let t826 = circuit_mul(in133, t825);
    let t827 = circuit_add(t820, t826);
    let t828 = circuit_sub(in234, in10);
    let t829 = circuit_mul(t822, t828);
    let t830 = circuit_sub(in234, in10);
    let t831 = circuit_mul(in6, t830);
    let t832 = circuit_inverse(t831);
    let t833 = circuit_mul(in134, t832);
    let t834 = circuit_add(t827, t833);
    let t835 = circuit_sub(in234, in11);
    let t836 = circuit_mul(t829, t835);
    let t837 = circuit_sub(in234, in11);
    let t838 = circuit_mul(in5, t837);
    let t839 = circuit_inverse(t838);
    let t840 = circuit_mul(in135, t839);
    let t841 = circuit_add(t834, t840);
    let t842 = circuit_sub(in234, in12);
    let t843 = circuit_mul(t836, t842);
    let t844 = circuit_sub(in234, in12);
    let t845 = circuit_mul(in4, t844);
    let t846 = circuit_inverse(t845);
    let t847 = circuit_mul(in136, t846);
    let t848 = circuit_add(t841, t847);
    let t849 = circuit_sub(in234, in13);
    let t850 = circuit_mul(t843, t849);
    let t851 = circuit_sub(in234, in13);
    let t852 = circuit_mul(in3, t851);
    let t853 = circuit_inverse(t852);
    let t854 = circuit_mul(in137, t853);
    let t855 = circuit_add(t848, t854);
    let t856 = circuit_sub(in234, in14);
    let t857 = circuit_mul(t850, t856);
    let t858 = circuit_sub(in234, in14);
    let t859 = circuit_mul(in2, t858);
    let t860 = circuit_inverse(t859);
    let t861 = circuit_mul(in138, t860);
    let t862 = circuit_add(t855, t861);
    let t863 = circuit_mul(t862, t857);
    let t864 = circuit_sub(in249, in0);
    let t865 = circuit_mul(in234, t864);
    let t866 = circuit_add(in0, t865);
    let t867 = circuit_mul(t794, t866);
    let t868 = circuit_add(in139, in140);
    let t869 = circuit_sub(t868, t863);
    let t870 = circuit_mul(t869, t799);
    let t871 = circuit_add(t798, t870);
    let t872 = circuit_mul(t799, in260);
    let t873 = circuit_sub(in235, in7);
    let t874 = circuit_mul(in0, t873);
    let t875 = circuit_sub(in235, in7);
    let t876 = circuit_mul(in2, t875);
    let t877 = circuit_inverse(t876);
    let t878 = circuit_mul(in139, t877);
    let t879 = circuit_add(in7, t878);
    let t880 = circuit_sub(in235, in0);
    let t881 = circuit_mul(t874, t880);
    let t882 = circuit_sub(in235, in0);
    let t883 = circuit_mul(in3, t882);
    let t884 = circuit_inverse(t883);
    let t885 = circuit_mul(in140, t884);
    let t886 = circuit_add(t879, t885);
    let t887 = circuit_sub(in235, in8);
    let t888 = circuit_mul(t881, t887);
    let t889 = circuit_sub(in235, in8);
    let t890 = circuit_mul(in4, t889);
    let t891 = circuit_inverse(t890);
    let t892 = circuit_mul(in141, t891);
    let t893 = circuit_add(t886, t892);
    let t894 = circuit_sub(in235, in9);
    let t895 = circuit_mul(t888, t894);
    let t896 = circuit_sub(in235, in9);
    let t897 = circuit_mul(in5, t896);
    let t898 = circuit_inverse(t897);
    let t899 = circuit_mul(in142, t898);
    let t900 = circuit_add(t893, t899);
    let t901 = circuit_sub(in235, in10);
    let t902 = circuit_mul(t895, t901);
    let t903 = circuit_sub(in235, in10);
    let t904 = circuit_mul(in6, t903);
    let t905 = circuit_inverse(t904);
    let t906 = circuit_mul(in143, t905);
    let t907 = circuit_add(t900, t906);
    let t908 = circuit_sub(in235, in11);
    let t909 = circuit_mul(t902, t908);
    let t910 = circuit_sub(in235, in11);
    let t911 = circuit_mul(in5, t910);
    let t912 = circuit_inverse(t911);
    let t913 = circuit_mul(in144, t912);
    let t914 = circuit_add(t907, t913);
    let t915 = circuit_sub(in235, in12);
    let t916 = circuit_mul(t909, t915);
    let t917 = circuit_sub(in235, in12);
    let t918 = circuit_mul(in4, t917);
    let t919 = circuit_inverse(t918);
    let t920 = circuit_mul(in145, t919);
    let t921 = circuit_add(t914, t920);
    let t922 = circuit_sub(in235, in13);
    let t923 = circuit_mul(t916, t922);
    let t924 = circuit_sub(in235, in13);
    let t925 = circuit_mul(in3, t924);
    let t926 = circuit_inverse(t925);
    let t927 = circuit_mul(in146, t926);
    let t928 = circuit_add(t921, t927);
    let t929 = circuit_sub(in235, in14);
    let t930 = circuit_mul(t923, t929);
    let t931 = circuit_sub(in235, in14);
    let t932 = circuit_mul(in2, t931);
    let t933 = circuit_inverse(t932);
    let t934 = circuit_mul(in147, t933);
    let t935 = circuit_add(t928, t934);
    let t936 = circuit_mul(t935, t930);
    let t937 = circuit_sub(in250, in0);
    let t938 = circuit_mul(in235, t937);
    let t939 = circuit_add(in0, t938);
    let t940 = circuit_mul(t867, t939);
    let t941 = circuit_add(in148, in149);
    let t942 = circuit_sub(t941, t936);
    let t943 = circuit_mul(t942, t872);
    let t944 = circuit_add(t871, t943);
    let t945 = circuit_mul(t872, in260);
    let t946 = circuit_sub(in236, in7);
    let t947 = circuit_mul(in0, t946);
    let t948 = circuit_sub(in236, in7);
    let t949 = circuit_mul(in2, t948);
    let t950 = circuit_inverse(t949);
    let t951 = circuit_mul(in148, t950);
    let t952 = circuit_add(in7, t951);
    let t953 = circuit_sub(in236, in0);
    let t954 = circuit_mul(t947, t953);
    let t955 = circuit_sub(in236, in0);
    let t956 = circuit_mul(in3, t955);
    let t957 = circuit_inverse(t956);
    let t958 = circuit_mul(in149, t957);
    let t959 = circuit_add(t952, t958);
    let t960 = circuit_sub(in236, in8);
    let t961 = circuit_mul(t954, t960);
    let t962 = circuit_sub(in236, in8);
    let t963 = circuit_mul(in4, t962);
    let t964 = circuit_inverse(t963);
    let t965 = circuit_mul(in150, t964);
    let t966 = circuit_add(t959, t965);
    let t967 = circuit_sub(in236, in9);
    let t968 = circuit_mul(t961, t967);
    let t969 = circuit_sub(in236, in9);
    let t970 = circuit_mul(in5, t969);
    let t971 = circuit_inverse(t970);
    let t972 = circuit_mul(in151, t971);
    let t973 = circuit_add(t966, t972);
    let t974 = circuit_sub(in236, in10);
    let t975 = circuit_mul(t968, t974);
    let t976 = circuit_sub(in236, in10);
    let t977 = circuit_mul(in6, t976);
    let t978 = circuit_inverse(t977);
    let t979 = circuit_mul(in152, t978);
    let t980 = circuit_add(t973, t979);
    let t981 = circuit_sub(in236, in11);
    let t982 = circuit_mul(t975, t981);
    let t983 = circuit_sub(in236, in11);
    let t984 = circuit_mul(in5, t983);
    let t985 = circuit_inverse(t984);
    let t986 = circuit_mul(in153, t985);
    let t987 = circuit_add(t980, t986);
    let t988 = circuit_sub(in236, in12);
    let t989 = circuit_mul(t982, t988);
    let t990 = circuit_sub(in236, in12);
    let t991 = circuit_mul(in4, t990);
    let t992 = circuit_inverse(t991);
    let t993 = circuit_mul(in154, t992);
    let t994 = circuit_add(t987, t993);
    let t995 = circuit_sub(in236, in13);
    let t996 = circuit_mul(t989, t995);
    let t997 = circuit_sub(in236, in13);
    let t998 = circuit_mul(in3, t997);
    let t999 = circuit_inverse(t998);
    let t1000 = circuit_mul(in155, t999);
    let t1001 = circuit_add(t994, t1000);
    let t1002 = circuit_sub(in236, in14);
    let t1003 = circuit_mul(t996, t1002);
    let t1004 = circuit_sub(in236, in14);
    let t1005 = circuit_mul(in2, t1004);
    let t1006 = circuit_inverse(t1005);
    let t1007 = circuit_mul(in156, t1006);
    let t1008 = circuit_add(t1001, t1007);
    let t1009 = circuit_mul(t1008, t1003);
    let t1010 = circuit_sub(in251, in0);
    let t1011 = circuit_mul(in236, t1010);
    let t1012 = circuit_add(in0, t1011);
    let t1013 = circuit_mul(t940, t1012);
    let t1014 = circuit_add(in157, in158);
    let t1015 = circuit_sub(t1014, t1009);
    let t1016 = circuit_mul(t1015, t945);
    let t1017 = circuit_add(t944, t1016);
    let t1018 = circuit_mul(t945, in260);
    let t1019 = circuit_sub(in237, in7);
    let t1020 = circuit_mul(in0, t1019);
    let t1021 = circuit_sub(in237, in7);
    let t1022 = circuit_mul(in2, t1021);
    let t1023 = circuit_inverse(t1022);
    let t1024 = circuit_mul(in157, t1023);
    let t1025 = circuit_add(in7, t1024);
    let t1026 = circuit_sub(in237, in0);
    let t1027 = circuit_mul(t1020, t1026);
    let t1028 = circuit_sub(in237, in0);
    let t1029 = circuit_mul(in3, t1028);
    let t1030 = circuit_inverse(t1029);
    let t1031 = circuit_mul(in158, t1030);
    let t1032 = circuit_add(t1025, t1031);
    let t1033 = circuit_sub(in237, in8);
    let t1034 = circuit_mul(t1027, t1033);
    let t1035 = circuit_sub(in237, in8);
    let t1036 = circuit_mul(in4, t1035);
    let t1037 = circuit_inverse(t1036);
    let t1038 = circuit_mul(in159, t1037);
    let t1039 = circuit_add(t1032, t1038);
    let t1040 = circuit_sub(in237, in9);
    let t1041 = circuit_mul(t1034, t1040);
    let t1042 = circuit_sub(in237, in9);
    let t1043 = circuit_mul(in5, t1042);
    let t1044 = circuit_inverse(t1043);
    let t1045 = circuit_mul(in160, t1044);
    let t1046 = circuit_add(t1039, t1045);
    let t1047 = circuit_sub(in237, in10);
    let t1048 = circuit_mul(t1041, t1047);
    let t1049 = circuit_sub(in237, in10);
    let t1050 = circuit_mul(in6, t1049);
    let t1051 = circuit_inverse(t1050);
    let t1052 = circuit_mul(in161, t1051);
    let t1053 = circuit_add(t1046, t1052);
    let t1054 = circuit_sub(in237, in11);
    let t1055 = circuit_mul(t1048, t1054);
    let t1056 = circuit_sub(in237, in11);
    let t1057 = circuit_mul(in5, t1056);
    let t1058 = circuit_inverse(t1057);
    let t1059 = circuit_mul(in162, t1058);
    let t1060 = circuit_add(t1053, t1059);
    let t1061 = circuit_sub(in237, in12);
    let t1062 = circuit_mul(t1055, t1061);
    let t1063 = circuit_sub(in237, in12);
    let t1064 = circuit_mul(in4, t1063);
    let t1065 = circuit_inverse(t1064);
    let t1066 = circuit_mul(in163, t1065);
    let t1067 = circuit_add(t1060, t1066);
    let t1068 = circuit_sub(in237, in13);
    let t1069 = circuit_mul(t1062, t1068);
    let t1070 = circuit_sub(in237, in13);
    let t1071 = circuit_mul(in3, t1070);
    let t1072 = circuit_inverse(t1071);
    let t1073 = circuit_mul(in164, t1072);
    let t1074 = circuit_add(t1067, t1073);
    let t1075 = circuit_sub(in237, in14);
    let t1076 = circuit_mul(t1069, t1075);
    let t1077 = circuit_sub(in237, in14);
    let t1078 = circuit_mul(in2, t1077);
    let t1079 = circuit_inverse(t1078);
    let t1080 = circuit_mul(in165, t1079);
    let t1081 = circuit_add(t1074, t1080);
    let t1082 = circuit_mul(t1081, t1076);
    let t1083 = circuit_sub(in252, in0);
    let t1084 = circuit_mul(in237, t1083);
    let t1085 = circuit_add(in0, t1084);
    let t1086 = circuit_mul(t1013, t1085);
    let t1087 = circuit_add(in166, in167);
    let t1088 = circuit_sub(t1087, t1082);
    let t1089 = circuit_mul(t1088, t1018);
    let t1090 = circuit_add(t1017, t1089);
    let t1091 = circuit_mul(t1018, in260);
    let t1092 = circuit_sub(in238, in7);
    let t1093 = circuit_mul(in0, t1092);
    let t1094 = circuit_sub(in238, in7);
    let t1095 = circuit_mul(in2, t1094);
    let t1096 = circuit_inverse(t1095);
    let t1097 = circuit_mul(in166, t1096);
    let t1098 = circuit_add(in7, t1097);
    let t1099 = circuit_sub(in238, in0);
    let t1100 = circuit_mul(t1093, t1099);
    let t1101 = circuit_sub(in238, in0);
    let t1102 = circuit_mul(in3, t1101);
    let t1103 = circuit_inverse(t1102);
    let t1104 = circuit_mul(in167, t1103);
    let t1105 = circuit_add(t1098, t1104);
    let t1106 = circuit_sub(in238, in8);
    let t1107 = circuit_mul(t1100, t1106);
    let t1108 = circuit_sub(in238, in8);
    let t1109 = circuit_mul(in4, t1108);
    let t1110 = circuit_inverse(t1109);
    let t1111 = circuit_mul(in168, t1110);
    let t1112 = circuit_add(t1105, t1111);
    let t1113 = circuit_sub(in238, in9);
    let t1114 = circuit_mul(t1107, t1113);
    let t1115 = circuit_sub(in238, in9);
    let t1116 = circuit_mul(in5, t1115);
    let t1117 = circuit_inverse(t1116);
    let t1118 = circuit_mul(in169, t1117);
    let t1119 = circuit_add(t1112, t1118);
    let t1120 = circuit_sub(in238, in10);
    let t1121 = circuit_mul(t1114, t1120);
    let t1122 = circuit_sub(in238, in10);
    let t1123 = circuit_mul(in6, t1122);
    let t1124 = circuit_inverse(t1123);
    let t1125 = circuit_mul(in170, t1124);
    let t1126 = circuit_add(t1119, t1125);
    let t1127 = circuit_sub(in238, in11);
    let t1128 = circuit_mul(t1121, t1127);
    let t1129 = circuit_sub(in238, in11);
    let t1130 = circuit_mul(in5, t1129);
    let t1131 = circuit_inverse(t1130);
    let t1132 = circuit_mul(in171, t1131);
    let t1133 = circuit_add(t1126, t1132);
    let t1134 = circuit_sub(in238, in12);
    let t1135 = circuit_mul(t1128, t1134);
    let t1136 = circuit_sub(in238, in12);
    let t1137 = circuit_mul(in4, t1136);
    let t1138 = circuit_inverse(t1137);
    let t1139 = circuit_mul(in172, t1138);
    let t1140 = circuit_add(t1133, t1139);
    let t1141 = circuit_sub(in238, in13);
    let t1142 = circuit_mul(t1135, t1141);
    let t1143 = circuit_sub(in238, in13);
    let t1144 = circuit_mul(in3, t1143);
    let t1145 = circuit_inverse(t1144);
    let t1146 = circuit_mul(in173, t1145);
    let t1147 = circuit_add(t1140, t1146);
    let t1148 = circuit_sub(in238, in14);
    let t1149 = circuit_mul(t1142, t1148);
    let t1150 = circuit_sub(in238, in14);
    let t1151 = circuit_mul(in2, t1150);
    let t1152 = circuit_inverse(t1151);
    let t1153 = circuit_mul(in174, t1152);
    let t1154 = circuit_add(t1147, t1153);
    let t1155 = circuit_mul(t1154, t1149);
    let t1156 = circuit_sub(in253, in0);
    let t1157 = circuit_mul(in238, t1156);
    let t1158 = circuit_add(in0, t1157);
    let t1159 = circuit_mul(t1086, t1158);
    let t1160 = circuit_add(in175, in176);
    let t1161 = circuit_sub(t1160, t1155);
    let t1162 = circuit_mul(t1161, t1091);
    let t1163 = circuit_add(t1090, t1162);
    let t1164 = circuit_sub(in239, in7);
    let t1165 = circuit_mul(in0, t1164);
    let t1166 = circuit_sub(in239, in7);
    let t1167 = circuit_mul(in2, t1166);
    let t1168 = circuit_inverse(t1167);
    let t1169 = circuit_mul(in175, t1168);
    let t1170 = circuit_add(in7, t1169);
    let t1171 = circuit_sub(in239, in0);
    let t1172 = circuit_mul(t1165, t1171);
    let t1173 = circuit_sub(in239, in0);
    let t1174 = circuit_mul(in3, t1173);
    let t1175 = circuit_inverse(t1174);
    let t1176 = circuit_mul(in176, t1175);
    let t1177 = circuit_add(t1170, t1176);
    let t1178 = circuit_sub(in239, in8);
    let t1179 = circuit_mul(t1172, t1178);
    let t1180 = circuit_sub(in239, in8);
    let t1181 = circuit_mul(in4, t1180);
    let t1182 = circuit_inverse(t1181);
    let t1183 = circuit_mul(in177, t1182);
    let t1184 = circuit_add(t1177, t1183);
    let t1185 = circuit_sub(in239, in9);
    let t1186 = circuit_mul(t1179, t1185);
    let t1187 = circuit_sub(in239, in9);
    let t1188 = circuit_mul(in5, t1187);
    let t1189 = circuit_inverse(t1188);
    let t1190 = circuit_mul(in178, t1189);
    let t1191 = circuit_add(t1184, t1190);
    let t1192 = circuit_sub(in239, in10);
    let t1193 = circuit_mul(t1186, t1192);
    let t1194 = circuit_sub(in239, in10);
    let t1195 = circuit_mul(in6, t1194);
    let t1196 = circuit_inverse(t1195);
    let t1197 = circuit_mul(in179, t1196);
    let t1198 = circuit_add(t1191, t1197);
    let t1199 = circuit_sub(in239, in11);
    let t1200 = circuit_mul(t1193, t1199);
    let t1201 = circuit_sub(in239, in11);
    let t1202 = circuit_mul(in5, t1201);
    let t1203 = circuit_inverse(t1202);
    let t1204 = circuit_mul(in180, t1203);
    let t1205 = circuit_add(t1198, t1204);
    let t1206 = circuit_sub(in239, in12);
    let t1207 = circuit_mul(t1200, t1206);
    let t1208 = circuit_sub(in239, in12);
    let t1209 = circuit_mul(in4, t1208);
    let t1210 = circuit_inverse(t1209);
    let t1211 = circuit_mul(in181, t1210);
    let t1212 = circuit_add(t1205, t1211);
    let t1213 = circuit_sub(in239, in13);
    let t1214 = circuit_mul(t1207, t1213);
    let t1215 = circuit_sub(in239, in13);
    let t1216 = circuit_mul(in3, t1215);
    let t1217 = circuit_inverse(t1216);
    let t1218 = circuit_mul(in182, t1217);
    let t1219 = circuit_add(t1212, t1218);
    let t1220 = circuit_sub(in239, in14);
    let t1221 = circuit_mul(t1214, t1220);
    let t1222 = circuit_sub(in239, in14);
    let t1223 = circuit_mul(in2, t1222);
    let t1224 = circuit_inverse(t1223);
    let t1225 = circuit_mul(in183, t1224);
    let t1226 = circuit_add(t1219, t1225);
    let t1227 = circuit_mul(t1226, t1221);
    let t1228 = circuit_sub(in254, in0);
    let t1229 = circuit_mul(in239, t1228);
    let t1230 = circuit_add(in0, t1229);
    let t1231 = circuit_mul(t1159, t1230);
    let t1232 = circuit_sub(in191, in9);
    let t1233 = circuit_mul(t1232, in184);
    let t1234 = circuit_mul(t1233, in212);
    let t1235 = circuit_mul(t1234, in211);
    let t1236 = circuit_mul(t1235, in15);
    let t1237 = circuit_mul(in186, in211);
    let t1238 = circuit_mul(in187, in212);
    let t1239 = circuit_mul(in188, in213);
    let t1240 = circuit_mul(in189, in214);
    let t1241 = circuit_add(t1236, t1237);
    let t1242 = circuit_add(t1241, t1238);
    let t1243 = circuit_add(t1242, t1239);
    let t1244 = circuit_add(t1243, t1240);
    let t1245 = circuit_add(t1244, in185);
    let t1246 = circuit_sub(in191, in0);
    let t1247 = circuit_mul(t1246, in222);
    let t1248 = circuit_add(t1245, t1247);
    let t1249 = circuit_mul(t1248, in191);
    let t1250 = circuit_mul(t1249, t1231);
    let t1251 = circuit_add(in211, in214);
    let t1252 = circuit_add(t1251, in184);
    let t1253 = circuit_sub(t1252, in219);
    let t1254 = circuit_sub(in191, in8);
    let t1255 = circuit_mul(t1253, t1254);
    let t1256 = circuit_sub(in191, in0);
    let t1257 = circuit_mul(t1255, t1256);
    let t1258 = circuit_mul(t1257, in191);
    let t1259 = circuit_mul(t1258, t1231);
    let t1260 = circuit_mul(in201, in258);
    let t1261 = circuit_add(in211, t1260);
    let t1262 = circuit_add(t1261, in259);
    let t1263 = circuit_mul(in202, in258);
    let t1264 = circuit_add(in212, t1263);
    let t1265 = circuit_add(t1264, in259);
    let t1266 = circuit_mul(t1262, t1265);
    let t1267 = circuit_mul(in203, in258);
    let t1268 = circuit_add(in213, t1267);
    let t1269 = circuit_add(t1268, in259);
    let t1270 = circuit_mul(t1266, t1269);
    let t1271 = circuit_mul(in204, in258);
    let t1272 = circuit_add(in214, t1271);
    let t1273 = circuit_add(t1272, in259);
    let t1274 = circuit_mul(t1270, t1273);
    let t1275 = circuit_mul(in197, in258);
    let t1276 = circuit_add(in211, t1275);
    let t1277 = circuit_add(t1276, in259);
    let t1278 = circuit_mul(in198, in258);
    let t1279 = circuit_add(in212, t1278);
    let t1280 = circuit_add(t1279, in259);
    let t1281 = circuit_mul(t1277, t1280);
    let t1282 = circuit_mul(in199, in258);
    let t1283 = circuit_add(in213, t1282);
    let t1284 = circuit_add(t1283, in259);
    let t1285 = circuit_mul(t1281, t1284);
    let t1286 = circuit_mul(in200, in258);
    let t1287 = circuit_add(in214, t1286);
    let t1288 = circuit_add(t1287, in259);
    let t1289 = circuit_mul(t1285, t1288);
    let t1290 = circuit_add(in215, in209);
    let t1291 = circuit_mul(t1274, t1290);
    let t1292 = circuit_mul(in210, t137);
    let t1293 = circuit_add(in223, t1292);
    let t1294 = circuit_mul(t1289, t1293);
    let t1295 = circuit_sub(t1291, t1294);
    let t1296 = circuit_mul(t1295, t1231);
    let t1297 = circuit_mul(in210, in223);
    let t1298 = circuit_mul(t1297, t1231);
    let t1299 = circuit_mul(in206, in255);
    let t1300 = circuit_mul(in207, in256);
    let t1301 = circuit_mul(in208, in257);
    let t1302 = circuit_add(in205, in259);
    let t1303 = circuit_add(t1302, t1299);
    let t1304 = circuit_add(t1303, t1300);
    let t1305 = circuit_add(t1304, t1301);
    let t1306 = circuit_mul(in187, in219);
    let t1307 = circuit_add(in211, in259);
    let t1308 = circuit_add(t1307, t1306);
    let t1309 = circuit_mul(in184, in220);
    let t1310 = circuit_add(in212, t1309);
    let t1311 = circuit_mul(in185, in221);
    let t1312 = circuit_add(in213, t1311);
    let t1313 = circuit_mul(t1310, in255);
    let t1314 = circuit_mul(t1312, in256);
    let t1315 = circuit_mul(in188, in257);
    let t1316 = circuit_add(t1308, t1313);
    let t1317 = circuit_add(t1316, t1314);
    let t1318 = circuit_add(t1317, t1315);
    let t1319 = circuit_mul(in216, t1305);
    let t1320 = circuit_mul(in216, t1318);
    let t1321 = circuit_add(in218, in190);
    let t1322 = circuit_mul(in218, in190);
    let t1323 = circuit_sub(t1321, t1322);
    let t1324 = circuit_mul(t1318, t1305);
    let t1325 = circuit_mul(t1324, in216);
    let t1326 = circuit_sub(t1325, t1323);
    let t1327 = circuit_mul(t1326, t1231);
    let t1328 = circuit_mul(in190, t1319);
    let t1329 = circuit_mul(in217, t1320);
    let t1330 = circuit_sub(t1328, t1329);
    let t1331 = circuit_mul(in192, t1231);
    let t1332 = circuit_sub(in212, in211);
    let t1333 = circuit_sub(in213, in212);
    let t1334 = circuit_sub(in214, in213);
    let t1335 = circuit_sub(in219, in214);
    let t1336 = circuit_add(t1332, in16);
    let t1337 = circuit_add(t1336, in16);
    let t1338 = circuit_add(t1337, in16);
    let t1339 = circuit_mul(t1332, t1336);
    let t1340 = circuit_mul(t1339, t1337);
    let t1341 = circuit_mul(t1340, t1338);
    let t1342 = circuit_mul(t1341, t1331);
    let t1343 = circuit_add(t1333, in16);
    let t1344 = circuit_add(t1343, in16);
    let t1345 = circuit_add(t1344, in16);
    let t1346 = circuit_mul(t1333, t1343);
    let t1347 = circuit_mul(t1346, t1344);
    let t1348 = circuit_mul(t1347, t1345);
    let t1349 = circuit_mul(t1348, t1331);
    let t1350 = circuit_add(t1334, in16);
    let t1351 = circuit_add(t1350, in16);
    let t1352 = circuit_add(t1351, in16);
    let t1353 = circuit_mul(t1334, t1350);
    let t1354 = circuit_mul(t1353, t1351);
    let t1355 = circuit_mul(t1354, t1352);
    let t1356 = circuit_mul(t1355, t1331);
    let t1357 = circuit_add(t1335, in16);
    let t1358 = circuit_add(t1357, in16);
    let t1359 = circuit_add(t1358, in16);
    let t1360 = circuit_mul(t1335, t1357);
    let t1361 = circuit_mul(t1360, t1358);
    let t1362 = circuit_mul(t1361, t1359);
    let t1363 = circuit_mul(t1362, t1331);
    let t1364 = circuit_sub(in219, in212);
    let t1365 = circuit_mul(in213, in213);
    let t1366 = circuit_mul(in222, in222);
    let t1367 = circuit_mul(in213, in222);
    let t1368 = circuit_mul(t1367, in186);
    let t1369 = circuit_add(in220, in219);
    let t1370 = circuit_add(t1369, in212);
    let t1371 = circuit_mul(t1370, t1364);
    let t1372 = circuit_mul(t1371, t1364);
    let t1373 = circuit_sub(t1372, t1366);
    let t1374 = circuit_sub(t1373, t1365);
    let t1375 = circuit_add(t1374, t1368);
    let t1376 = circuit_add(t1375, t1368);
    let t1377 = circuit_sub(in0, in184);
    let t1378 = circuit_mul(t1376, t1231);
    let t1379 = circuit_mul(t1378, in193);
    let t1380 = circuit_mul(t1379, t1377);
    let t1381 = circuit_add(in213, in221);
    let t1382 = circuit_mul(in222, in186);
    let t1383 = circuit_sub(t1382, in213);
    let t1384 = circuit_mul(t1381, t1364);
    let t1385 = circuit_sub(in220, in212);
    let t1386 = circuit_mul(t1385, t1383);
    let t1387 = circuit_add(t1384, t1386);
    let t1388 = circuit_mul(t1387, t1231);
    let t1389 = circuit_mul(t1388, in193);
    let t1390 = circuit_mul(t1389, t1377);
    let t1391 = circuit_add(t1365, in17);
    let t1392 = circuit_mul(t1391, in212);
    let t1393 = circuit_add(t1365, t1365);
    let t1394 = circuit_add(t1393, t1393);
    let t1395 = circuit_mul(t1392, in18);
    let t1396 = circuit_add(in220, in212);
    let t1397 = circuit_add(t1396, in212);
    let t1398 = circuit_mul(t1397, t1394);
    let t1399 = circuit_sub(t1398, t1395);
    let t1400 = circuit_mul(t1399, t1231);
    let t1401 = circuit_mul(t1400, in193);
    let t1402 = circuit_mul(t1401, in184);
    let t1403 = circuit_add(t1380, t1402);
    let t1404 = circuit_add(in212, in212);
    let t1405 = circuit_add(t1404, in212);
    let t1406 = circuit_mul(t1405, in212);
    let t1407 = circuit_sub(in212, in220);
    let t1408 = circuit_mul(t1406, t1407);
    let t1409 = circuit_add(in213, in213);
    let t1410 = circuit_add(in213, in221);
    let t1411 = circuit_mul(t1409, t1410);
    let t1412 = circuit_sub(t1408, t1411);
    let t1413 = circuit_mul(t1412, t1231);
    let t1414 = circuit_mul(t1413, in193);
    let t1415 = circuit_mul(t1414, in184);
    let t1416 = circuit_add(t1390, t1415);
    let t1417 = circuit_mul(in211, in220);
    let t1418 = circuit_mul(in219, in212);
    let t1419 = circuit_add(t1417, t1418);
    let t1420 = circuit_mul(in211, in214);
    let t1421 = circuit_mul(in212, in213);
    let t1422 = circuit_add(t1420, t1421);
    let t1423 = circuit_sub(t1422, in221);
    let t1424 = circuit_mul(t1423, in19);
    let t1425 = circuit_sub(t1424, in222);
    let t1426 = circuit_add(t1425, t1419);
    let t1427 = circuit_mul(t1426, in189);
    let t1428 = circuit_mul(t1419, in19);
    let t1429 = circuit_mul(in219, in220);
    let t1430 = circuit_add(t1428, t1429);
    let t1431 = circuit_add(in213, in214);
    let t1432 = circuit_sub(t1430, t1431);
    let t1433 = circuit_mul(t1432, in188);
    let t1434 = circuit_add(t1430, in214);
    let t1435 = circuit_add(in221, in222);
    let t1436 = circuit_sub(t1434, t1435);
    let t1437 = circuit_mul(t1436, in184);
    let t1438 = circuit_add(t1433, t1427);
    let t1439 = circuit_add(t1438, t1437);
    let t1440 = circuit_mul(t1439, in187);
    let t1441 = circuit_mul(in220, in20);
    let t1442 = circuit_add(t1441, in219);
    let t1443 = circuit_mul(t1442, in20);
    let t1444 = circuit_add(t1443, in213);
    let t1445 = circuit_mul(t1444, in20);
    let t1446 = circuit_add(t1445, in212);
    let t1447 = circuit_mul(t1446, in20);
    let t1448 = circuit_add(t1447, in211);
    let t1449 = circuit_sub(t1448, in214);
    let t1450 = circuit_mul(t1449, in189);
    let t1451 = circuit_mul(in221, in20);
    let t1452 = circuit_add(t1451, in220);
    let t1453 = circuit_mul(t1452, in20);
    let t1454 = circuit_add(t1453, in219);
    let t1455 = circuit_mul(t1454, in20);
    let t1456 = circuit_add(t1455, in214);
    let t1457 = circuit_mul(t1456, in20);
    let t1458 = circuit_add(t1457, in213);
    let t1459 = circuit_sub(t1458, in222);
    let t1460 = circuit_mul(t1459, in184);
    let t1461 = circuit_add(t1450, t1460);
    let t1462 = circuit_mul(t1461, in188);
    let t1463 = circuit_mul(in213, in257);
    let t1464 = circuit_mul(in212, in256);
    let t1465 = circuit_mul(in211, in255);
    let t1466 = circuit_add(t1463, t1464);
    let t1467 = circuit_add(t1466, t1465);
    let t1468 = circuit_add(t1467, in185);
    let t1469 = circuit_sub(t1468, in214);
    let t1470 = circuit_sub(in219, in211);
    let t1471 = circuit_sub(in222, in214);
    let t1472 = circuit_mul(t1470, t1470);
    let t1473 = circuit_sub(t1472, t1470);
    let t1474 = circuit_sub(in7, t1470);
    let t1475 = circuit_add(t1474, in0);
    let t1476 = circuit_mul(t1475, t1471);
    let t1477 = circuit_mul(in186, in187);
    let t1478 = circuit_mul(t1477, in194);
    let t1479 = circuit_mul(t1478, t1231);
    let t1480 = circuit_mul(t1476, t1479);
    let t1481 = circuit_mul(t1473, t1479);
    let t1482 = circuit_mul(t1469, t1477);
    let t1483 = circuit_sub(in214, t1468);
    let t1484 = circuit_mul(t1483, t1483);
    let t1485 = circuit_sub(t1484, t1483);
    let t1486 = circuit_mul(in221, in257);
    let t1487 = circuit_mul(in220, in256);
    let t1488 = circuit_mul(in219, in255);
    let t1489 = circuit_add(t1486, t1487);
    let t1490 = circuit_add(t1489, t1488);
    let t1491 = circuit_sub(in222, t1490);
    let t1492 = circuit_sub(in221, in213);
    let t1493 = circuit_sub(in7, t1470);
    let t1494 = circuit_add(t1493, in0);
    let t1495 = circuit_sub(in7, t1491);
    let t1496 = circuit_add(t1495, in0);
    let t1497 = circuit_mul(t1492, t1496);
    let t1498 = circuit_mul(t1494, t1497);
    let t1499 = circuit_mul(t1491, t1491);
    let t1500 = circuit_sub(t1499, t1491);
    let t1501 = circuit_mul(in191, in194);
    let t1502 = circuit_mul(t1501, t1231);
    let t1503 = circuit_mul(t1498, t1502);
    let t1504 = circuit_mul(t1473, t1502);
    let t1505 = circuit_mul(t1500, t1502);
    let t1506 = circuit_mul(t1485, in191);
    let t1507 = circuit_sub(in220, in212);
    let t1508 = circuit_sub(in7, t1470);
    let t1509 = circuit_add(t1508, in0);
    let t1510 = circuit_mul(t1509, t1507);
    let t1511 = circuit_sub(t1510, in213);
    let t1512 = circuit_mul(t1511, in189);
    let t1513 = circuit_mul(t1512, in186);
    let t1514 = circuit_add(t1482, t1513);
    let t1515 = circuit_mul(t1469, in184);
    let t1516 = circuit_mul(t1515, in186);
    let t1517 = circuit_add(t1514, t1516);
    let t1518 = circuit_add(t1517, t1506);
    let t1519 = circuit_add(t1518, t1440);
    let t1520 = circuit_add(t1519, t1462);
    let t1521 = circuit_mul(t1520, in194);
    let t1522 = circuit_mul(t1521, t1231);
    let t1523 = circuit_add(in211, in186);
    let t1524 = circuit_add(in212, in187);
    let t1525 = circuit_add(in213, in188);
    let t1526 = circuit_add(in214, in189);
    let t1527 = circuit_mul(t1523, t1523);
    let t1528 = circuit_mul(t1527, t1527);
    let t1529 = circuit_mul(t1528, t1523);
    let t1530 = circuit_mul(t1524, t1524);
    let t1531 = circuit_mul(t1530, t1530);
    let t1532 = circuit_mul(t1531, t1524);
    let t1533 = circuit_mul(t1525, t1525);
    let t1534 = circuit_mul(t1533, t1533);
    let t1535 = circuit_mul(t1534, t1525);
    let t1536 = circuit_mul(t1526, t1526);
    let t1537 = circuit_mul(t1536, t1536);
    let t1538 = circuit_mul(t1537, t1526);
    let t1539 = circuit_add(t1529, t1532);
    let t1540 = circuit_add(t1535, t1538);
    let t1541 = circuit_add(t1532, t1532);
    let t1542 = circuit_add(t1541, t1540);
    let t1543 = circuit_add(t1538, t1538);
    let t1544 = circuit_add(t1543, t1539);
    let t1545 = circuit_add(t1540, t1540);
    let t1546 = circuit_add(t1545, t1545);
    let t1547 = circuit_add(t1546, t1544);
    let t1548 = circuit_add(t1539, t1539);
    let t1549 = circuit_add(t1548, t1548);
    let t1550 = circuit_add(t1549, t1542);
    let t1551 = circuit_add(t1544, t1550);
    let t1552 = circuit_add(t1542, t1547);
    let t1553 = circuit_mul(in195, t1231);
    let t1554 = circuit_sub(t1551, in219);
    let t1555 = circuit_mul(t1553, t1554);
    let t1556 = circuit_sub(t1550, in220);
    let t1557 = circuit_mul(t1553, t1556);
    let t1558 = circuit_sub(t1552, in221);
    let t1559 = circuit_mul(t1553, t1558);
    let t1560 = circuit_sub(t1547, in222);
    let t1561 = circuit_mul(t1553, t1560);
    let t1562 = circuit_add(in211, in186);
    let t1563 = circuit_mul(t1562, t1562);
    let t1564 = circuit_mul(t1563, t1563);
    let t1565 = circuit_mul(t1564, t1562);
    let t1566 = circuit_add(t1565, in212);
    let t1567 = circuit_add(t1566, in213);
    let t1568 = circuit_add(t1567, in214);
    let t1569 = circuit_mul(in196, t1231);
    let t1570 = circuit_mul(t1565, in21);
    let t1571 = circuit_add(t1570, t1568);
    let t1572 = circuit_sub(t1571, in219);
    let t1573 = circuit_mul(t1569, t1572);
    let t1574 = circuit_mul(in212, in22);
    let t1575 = circuit_add(t1574, t1568);
    let t1576 = circuit_sub(t1575, in220);
    let t1577 = circuit_mul(t1569, t1576);
    let t1578 = circuit_mul(in213, in23);
    let t1579 = circuit_add(t1578, t1568);
    let t1580 = circuit_sub(t1579, in221);
    let t1581 = circuit_mul(t1569, t1580);
    let t1582 = circuit_mul(in214, in24);
    let t1583 = circuit_add(t1582, t1568);
    let t1584 = circuit_sub(t1583, in222);
    let t1585 = circuit_mul(t1569, t1584);
    let t1586 = circuit_mul(t1259, in261);
    let t1587 = circuit_add(t1250, t1586);
    let t1588 = circuit_mul(t1296, in262);
    let t1589 = circuit_add(t1587, t1588);
    let t1590 = circuit_mul(t1298, in263);
    let t1591 = circuit_add(t1589, t1590);
    let t1592 = circuit_mul(t1327, in264);
    let t1593 = circuit_add(t1591, t1592);
    let t1594 = circuit_mul(t1330, in265);
    let t1595 = circuit_add(t1593, t1594);
    let t1596 = circuit_mul(t1342, in266);
    let t1597 = circuit_add(t1595, t1596);
    let t1598 = circuit_mul(t1349, in267);
    let t1599 = circuit_add(t1597, t1598);
    let t1600 = circuit_mul(t1356, in268);
    let t1601 = circuit_add(t1599, t1600);
    let t1602 = circuit_mul(t1363, in269);
    let t1603 = circuit_add(t1601, t1602);
    let t1604 = circuit_mul(t1403, in270);
    let t1605 = circuit_add(t1603, t1604);
    let t1606 = circuit_mul(t1416, in271);
    let t1607 = circuit_add(t1605, t1606);
    let t1608 = circuit_mul(t1522, in272);
    let t1609 = circuit_add(t1607, t1608);
    let t1610 = circuit_mul(t1480, in273);
    let t1611 = circuit_add(t1609, t1610);
    let t1612 = circuit_mul(t1481, in274);
    let t1613 = circuit_add(t1611, t1612);
    let t1614 = circuit_mul(t1503, in275);
    let t1615 = circuit_add(t1613, t1614);
    let t1616 = circuit_mul(t1504, in276);
    let t1617 = circuit_add(t1615, t1616);
    let t1618 = circuit_mul(t1505, in277);
    let t1619 = circuit_add(t1617, t1618);
    let t1620 = circuit_mul(t1555, in278);
    let t1621 = circuit_add(t1619, t1620);
    let t1622 = circuit_mul(t1557, in279);
    let t1623 = circuit_add(t1621, t1622);
    let t1624 = circuit_mul(t1559, in280);
    let t1625 = circuit_add(t1623, t1624);
    let t1626 = circuit_mul(t1561, in281);
    let t1627 = circuit_add(t1625, t1626);
    let t1628 = circuit_mul(t1573, in282);
    let t1629 = circuit_add(t1627, t1628);
    let t1630 = circuit_mul(t1577, in283);
    let t1631 = circuit_add(t1629, t1630);
    let t1632 = circuit_mul(t1581, in284);
    let t1633 = circuit_add(t1631, t1632);
    let t1634 = circuit_mul(t1585, in285);
    let t1635 = circuit_add(t1633, t1634);
    let t1636 = circuit_mul(in0, in227);
    let t1637 = circuit_mul(t1636, in228);
    let t1638 = circuit_mul(t1637, in229);
    let t1639 = circuit_mul(t1638, in230);
    let t1640 = circuit_mul(t1639, in231);
    let t1641 = circuit_mul(t1640, in232);
    let t1642 = circuit_mul(t1641, in233);
    let t1643 = circuit_mul(t1642, in234);
    let t1644 = circuit_mul(t1643, in235);
    let t1645 = circuit_mul(t1644, in236);
    let t1646 = circuit_mul(t1645, in237);
    let t1647 = circuit_mul(t1646, in238);
    let t1648 = circuit_mul(t1647, in239);
    let t1649 = circuit_sub(in0, t1648);
    let t1650 = circuit_mul(t1635, t1649);
    let t1651 = circuit_mul(in224, in286);
    let t1652 = circuit_add(t1650, t1651);
    let t1653 = circuit_sub(t1652, t1227);

    let modulus = modulus;

    let mut circuit_inputs = (t1163, t1653).new_inputs();
    // Prefill constants:

    circuit_inputs = circuit_inputs
        .next_span(ZK_HONK_SUMCHECK_SIZE_15_PUB_22_GRUMPKIN_CONSTANTS.span()); // in0 - in24

    // Fill inputs:

    for val in p_public_inputs {
        circuit_inputs = circuit_inputs.next_u256(*val);
    } // in25 - in30

    for val in p_pairing_point_object {
        circuit_inputs = circuit_inputs.next_u256(*val);
    } // in31 - in46

    circuit_inputs = circuit_inputs.next_2(p_public_inputs_offset); // in47
    circuit_inputs = circuit_inputs.next_2(libra_sum); // in48

    for val in sumcheck_univariates_flat {
        circuit_inputs = circuit_inputs.next_u256(*val);
    } // in49 - in183

    for val in sumcheck_evaluations {
        circuit_inputs = circuit_inputs.next_u256(*val);
    } // in184 - in223

    circuit_inputs = circuit_inputs.next_2(libra_evaluation); // in224

    for val in tp_sum_check_u_challenges {
        circuit_inputs = circuit_inputs.next_u128(*val);
    } // in225 - in239

    for val in tp_gate_challenges {
        circuit_inputs = circuit_inputs.next_u128(*val);
    } // in240 - in254

    circuit_inputs = circuit_inputs.next_2(tp_eta_1); // in255
    circuit_inputs = circuit_inputs.next_2(tp_eta_2); // in256
    circuit_inputs = circuit_inputs.next_2(tp_eta_3); // in257
    circuit_inputs = circuit_inputs.next_2(tp_beta); // in258
    circuit_inputs = circuit_inputs.next_2(tp_gamma); // in259
    circuit_inputs = circuit_inputs.next_2(tp_base_rlc); // in260

    for val in tp_alphas {
        circuit_inputs = circuit_inputs.next_u128(*val);
    } // in261 - in285

    circuit_inputs = circuit_inputs.next_2(tp_libra_challenge); // in286

    let outputs = circuit_inputs.done_2().eval(modulus).unwrap();
    let check_rlc: u384 = outputs.get_output(t1163);
    let check: u384 = outputs.get_output(t1653);
    return (check_rlc, check);
}
const ZK_HONK_SUMCHECK_SIZE_15_PUB_22_GRUMPKIN_CONSTANTS: [u384; 25] = [
    u384 { limb0: 0x1, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x8000, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x9d80, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 {
        limb0: 0x79b9709143e1f593efffec51,
        limb1: 0xb85045b68181585d2833e848,
        limb2: 0x30644e72e131a029,
        limb3: 0x0,
    },
    u384 { limb0: 0x5a0, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 {
        limb0: 0x79b9709143e1f593effffd31,
        limb1: 0xb85045b68181585d2833e848,
        limb2: 0x30644e72e131a029,
        limb3: 0x0,
    },
    u384 { limb0: 0x240, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x0, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x2, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x3, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x4, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x5, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x6, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x7, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x8, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 {
        limb0: 0x3cdcb848a1f0fac9f8000000,
        limb1: 0xdc2822db40c0ac2e9419f424,
        limb2: 0x183227397098d014,
        limb3: 0x0,
    },
    u384 {
        limb0: 0x79b9709143e1f593f0000000,
        limb1: 0xb85045b68181585d2833e848,
        limb2: 0x30644e72e131a029,
        limb3: 0x0,
    },
    u384 { limb0: 0x11, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x9, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x100000000000000000, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x4000, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 {
        limb0: 0x29ca1d7fb56821fd19d3b6e7,
        limb1: 0x4b1e03b4bd9490c0d03f989,
        limb2: 0x10dc6e9c006ea38b,
        limb3: 0x0,
    },
    u384 {
        limb0: 0xd4dd9b84a86b38cfb45a740b,
        limb1: 0x149b3d0a30b3bb599df9756,
        limb2: 0xc28145b6a44df3e,
        limb3: 0x0,
    },
    u384 {
        limb0: 0x60e3596170067d00141cac15,
        limb1: 0xb2c7645a50392798b21f75bb,
        limb2: 0x544b8338791518,
        limb3: 0x0,
    },
    u384 {
        limb0: 0xb8fa852613bc534433ee428b,
        limb1: 0x2e2e82eb122789e352e105a3,
        limb2: 0x222c01175718386f,
        limb3: 0x0,
    },
];
#[inline(always)]
pub fn run_GRUMPKIN_ZKHONK_PREP_MSM_SCALARS_SIZE_15_circuit(
    p_sumcheck_evaluations: Span<u256>,
    p_gemini_masking_eval: u384,
    p_gemini_a_evaluations: Span<u256>,
    p_libra_poly_evals: Span<u256>,
    tp_gemini_r: u384,
    tp_rho: u384,
    tp_shplonk_z: u384,
    tp_shplonk_nu: u384,
    tp_sum_check_u_challenges: Span<u128>,
    modulus: CircuitModulus,
) -> (
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
) {
    // CONSTANT stack
    let in0 = CE::<CI<0>> {}; // 0x0
    let in1 = CE::<CI<1>> {}; // 0x1
    let in2 = CE::<CI<2>> {}; // 0x7b0c561a6148404f086204a9f36ffb0617942546750f230c893619174a57a76

    // INPUT stack
    let (in3, in4, in5) = (CE::<CI<3>> {}, CE::<CI<4>> {}, CE::<CI<5>> {});
    let (in6, in7, in8) = (CE::<CI<6>> {}, CE::<CI<7>> {}, CE::<CI<8>> {});
    let (in9, in10, in11) = (CE::<CI<9>> {}, CE::<CI<10>> {}, CE::<CI<11>> {});
    let (in12, in13, in14) = (CE::<CI<12>> {}, CE::<CI<13>> {}, CE::<CI<14>> {});
    let (in15, in16, in17) = (CE::<CI<15>> {}, CE::<CI<16>> {}, CE::<CI<17>> {});
    let (in18, in19, in20) = (CE::<CI<18>> {}, CE::<CI<19>> {}, CE::<CI<20>> {});
    let (in21, in22, in23) = (CE::<CI<21>> {}, CE::<CI<22>> {}, CE::<CI<23>> {});
    let (in24, in25, in26) = (CE::<CI<24>> {}, CE::<CI<25>> {}, CE::<CI<26>> {});
    let (in27, in28, in29) = (CE::<CI<27>> {}, CE::<CI<28>> {}, CE::<CI<29>> {});
    let (in30, in31, in32) = (CE::<CI<30>> {}, CE::<CI<31>> {}, CE::<CI<32>> {});
    let (in33, in34, in35) = (CE::<CI<33>> {}, CE::<CI<34>> {}, CE::<CI<35>> {});
    let (in36, in37, in38) = (CE::<CI<36>> {}, CE::<CI<37>> {}, CE::<CI<38>> {});
    let (in39, in40, in41) = (CE::<CI<39>> {}, CE::<CI<40>> {}, CE::<CI<41>> {});
    let (in42, in43, in44) = (CE::<CI<42>> {}, CE::<CI<43>> {}, CE::<CI<44>> {});
    let (in45, in46, in47) = (CE::<CI<45>> {}, CE::<CI<46>> {}, CE::<CI<47>> {});
    let (in48, in49, in50) = (CE::<CI<48>> {}, CE::<CI<49>> {}, CE::<CI<50>> {});
    let (in51, in52, in53) = (CE::<CI<51>> {}, CE::<CI<52>> {}, CE::<CI<53>> {});
    let (in54, in55, in56) = (CE::<CI<54>> {}, CE::<CI<55>> {}, CE::<CI<56>> {});
    let (in57, in58, in59) = (CE::<CI<57>> {}, CE::<CI<58>> {}, CE::<CI<59>> {});
    let (in60, in61, in62) = (CE::<CI<60>> {}, CE::<CI<61>> {}, CE::<CI<62>> {});
    let (in63, in64, in65) = (CE::<CI<63>> {}, CE::<CI<64>> {}, CE::<CI<65>> {});
    let (in66, in67, in68) = (CE::<CI<66>> {}, CE::<CI<67>> {}, CE::<CI<68>> {});
    let (in69, in70, in71) = (CE::<CI<69>> {}, CE::<CI<70>> {}, CE::<CI<71>> {});
    let (in72, in73, in74) = (CE::<CI<72>> {}, CE::<CI<73>> {}, CE::<CI<74>> {});
    let (in75, in76, in77) = (CE::<CI<75>> {}, CE::<CI<76>> {}, CE::<CI<77>> {});
    let (in78, in79, in80) = (CE::<CI<78>> {}, CE::<CI<79>> {}, CE::<CI<80>> {});
    let in81 = CE::<CI<81>> {};
    let t0 = circuit_mul(in63, in63);
    let t1 = circuit_mul(t0, t0);
    let t2 = circuit_mul(t1, t1);
    let t3 = circuit_mul(t2, t2);
    let t4 = circuit_mul(t3, t3);
    let t5 = circuit_mul(t4, t4);
    let t6 = circuit_mul(t5, t5);
    let t7 = circuit_mul(t6, t6);
    let t8 = circuit_mul(t7, t7);
    let t9 = circuit_mul(t8, t8);
    let t10 = circuit_mul(t9, t9);
    let t11 = circuit_mul(t10, t10);
    let t12 = circuit_mul(t11, t11);
    let t13 = circuit_mul(t12, t12);
    let t14 = circuit_sub(in65, in63);
    let t15 = circuit_inverse(t14);
    let t16 = circuit_add(in65, in63);
    let t17 = circuit_inverse(t16);
    let t18 = circuit_mul(in66, t17);
    let t19 = circuit_add(t15, t18);
    let t20 = circuit_sub(in0, t19);
    let t21 = circuit_inverse(in63);
    let t22 = circuit_mul(in66, t17);
    let t23 = circuit_sub(t15, t22);
    let t24 = circuit_mul(t21, t23);
    let t25 = circuit_sub(in0, t24);
    let t26 = circuit_mul(t20, in64);
    let t27 = circuit_mul(in3, in64);
    let t28 = circuit_add(in43, t27);
    let t29 = circuit_mul(in64, in64);
    let t30 = circuit_mul(t20, t29);
    let t31 = circuit_mul(in4, t29);
    let t32 = circuit_add(t28, t31);
    let t33 = circuit_mul(t29, in64);
    let t34 = circuit_mul(t20, t33);
    let t35 = circuit_mul(in5, t33);
    let t36 = circuit_add(t32, t35);
    let t37 = circuit_mul(t33, in64);
    let t38 = circuit_mul(t20, t37);
    let t39 = circuit_mul(in6, t37);
    let t40 = circuit_add(t36, t39);
    let t41 = circuit_mul(t37, in64);
    let t42 = circuit_mul(t20, t41);
    let t43 = circuit_mul(in7, t41);
    let t44 = circuit_add(t40, t43);
    let t45 = circuit_mul(t41, in64);
    let t46 = circuit_mul(t20, t45);
    let t47 = circuit_mul(in8, t45);
    let t48 = circuit_add(t44, t47);
    let t49 = circuit_mul(t45, in64);
    let t50 = circuit_mul(t20, t49);
    let t51 = circuit_mul(in9, t49);
    let t52 = circuit_add(t48, t51);
    let t53 = circuit_mul(t49, in64);
    let t54 = circuit_mul(t20, t53);
    let t55 = circuit_mul(in10, t53);
    let t56 = circuit_add(t52, t55);
    let t57 = circuit_mul(t53, in64);
    let t58 = circuit_mul(t20, t57);
    let t59 = circuit_mul(in11, t57);
    let t60 = circuit_add(t56, t59);
    let t61 = circuit_mul(t57, in64);
    let t62 = circuit_mul(t20, t61);
    let t63 = circuit_mul(in12, t61);
    let t64 = circuit_add(t60, t63);
    let t65 = circuit_mul(t61, in64);
    let t66 = circuit_mul(t20, t65);
    let t67 = circuit_mul(in13, t65);
    let t68 = circuit_add(t64, t67);
    let t69 = circuit_mul(t65, in64);
    let t70 = circuit_mul(t20, t69);
    let t71 = circuit_mul(in14, t69);
    let t72 = circuit_add(t68, t71);
    let t73 = circuit_mul(t69, in64);
    let t74 = circuit_mul(t20, t73);
    let t75 = circuit_mul(in15, t73);
    let t76 = circuit_add(t72, t75);
    let t77 = circuit_mul(t73, in64);
    let t78 = circuit_mul(t20, t77);
    let t79 = circuit_mul(in16, t77);
    let t80 = circuit_add(t76, t79);
    let t81 = circuit_mul(t77, in64);
    let t82 = circuit_mul(t20, t81);
    let t83 = circuit_mul(in17, t81);
    let t84 = circuit_add(t80, t83);
    let t85 = circuit_mul(t81, in64);
    let t86 = circuit_mul(t20, t85);
    let t87 = circuit_mul(in18, t85);
    let t88 = circuit_add(t84, t87);
    let t89 = circuit_mul(t85, in64);
    let t90 = circuit_mul(t20, t89);
    let t91 = circuit_mul(in19, t89);
    let t92 = circuit_add(t88, t91);
    let t93 = circuit_mul(t89, in64);
    let t94 = circuit_mul(t20, t93);
    let t95 = circuit_mul(in20, t93);
    let t96 = circuit_add(t92, t95);
    let t97 = circuit_mul(t93, in64);
    let t98 = circuit_mul(t20, t97);
    let t99 = circuit_mul(in21, t97);
    let t100 = circuit_add(t96, t99);
    let t101 = circuit_mul(t97, in64);
    let t102 = circuit_mul(t20, t101);
    let t103 = circuit_mul(in22, t101);
    let t104 = circuit_add(t100, t103);
    let t105 = circuit_mul(t101, in64);
    let t106 = circuit_mul(t20, t105);
    let t107 = circuit_mul(in23, t105);
    let t108 = circuit_add(t104, t107);
    let t109 = circuit_mul(t105, in64);
    let t110 = circuit_mul(t20, t109);
    let t111 = circuit_mul(in24, t109);
    let t112 = circuit_add(t108, t111);
    let t113 = circuit_mul(t109, in64);
    let t114 = circuit_mul(t20, t113);
    let t115 = circuit_mul(in25, t113);
    let t116 = circuit_add(t112, t115);
    let t117 = circuit_mul(t113, in64);
    let t118 = circuit_mul(t20, t117);
    let t119 = circuit_mul(in26, t117);
    let t120 = circuit_add(t116, t119);
    let t121 = circuit_mul(t117, in64);
    let t122 = circuit_mul(t20, t121);
    let t123 = circuit_mul(in27, t121);
    let t124 = circuit_add(t120, t123);
    let t125 = circuit_mul(t121, in64);
    let t126 = circuit_mul(t20, t125);
    let t127 = circuit_mul(in28, t125);
    let t128 = circuit_add(t124, t127);
    let t129 = circuit_mul(t125, in64);
    let t130 = circuit_mul(t20, t129);
    let t131 = circuit_mul(in29, t129);
    let t132 = circuit_add(t128, t131);
    let t133 = circuit_mul(t129, in64);
    let t134 = circuit_mul(t20, t133);
    let t135 = circuit_mul(in30, t133);
    let t136 = circuit_add(t132, t135);
    let t137 = circuit_mul(t133, in64);
    let t138 = circuit_mul(t20, t137);
    let t139 = circuit_mul(in31, t137);
    let t140 = circuit_add(t136, t139);
    let t141 = circuit_mul(t137, in64);
    let t142 = circuit_mul(t20, t141);
    let t143 = circuit_mul(in32, t141);
    let t144 = circuit_add(t140, t143);
    let t145 = circuit_mul(t141, in64);
    let t146 = circuit_mul(t20, t145);
    let t147 = circuit_mul(in33, t145);
    let t148 = circuit_add(t144, t147);
    let t149 = circuit_mul(t145, in64);
    let t150 = circuit_mul(t20, t149);
    let t151 = circuit_mul(in34, t149);
    let t152 = circuit_add(t148, t151);
    let t153 = circuit_mul(t149, in64);
    let t154 = circuit_mul(t20, t153);
    let t155 = circuit_mul(in35, t153);
    let t156 = circuit_add(t152, t155);
    let t157 = circuit_mul(t153, in64);
    let t158 = circuit_mul(t20, t157);
    let t159 = circuit_mul(in36, t157);
    let t160 = circuit_add(t156, t159);
    let t161 = circuit_mul(t157, in64);
    let t162 = circuit_mul(t20, t161);
    let t163 = circuit_mul(in37, t161);
    let t164 = circuit_add(t160, t163);
    let t165 = circuit_mul(t161, in64);
    let t166 = circuit_mul(t25, t165);
    let t167 = circuit_mul(in38, t165);
    let t168 = circuit_add(t164, t167);
    let t169 = circuit_mul(t165, in64);
    let t170 = circuit_mul(t25, t169);
    let t171 = circuit_mul(in39, t169);
    let t172 = circuit_add(t168, t171);
    let t173 = circuit_mul(t169, in64);
    let t174 = circuit_mul(t25, t173);
    let t175 = circuit_mul(in40, t173);
    let t176 = circuit_add(t172, t175);
    let t177 = circuit_mul(t173, in64);
    let t178 = circuit_mul(t25, t177);
    let t179 = circuit_mul(in41, t177);
    let t180 = circuit_add(t176, t179);
    let t181 = circuit_mul(t177, in64);
    let t182 = circuit_mul(t25, t181);
    let t183 = circuit_mul(in42, t181);
    let t184 = circuit_add(t180, t183);
    let t185 = circuit_sub(in1, in81);
    let t186 = circuit_mul(t13, t185);
    let t187 = circuit_mul(t13, t184);
    let t188 = circuit_add(t187, t187);
    let t189 = circuit_sub(t186, in81);
    let t190 = circuit_mul(in58, t189);
    let t191 = circuit_sub(t188, t190);
    let t192 = circuit_add(t186, in81);
    let t193 = circuit_inverse(t192);
    let t194 = circuit_mul(t191, t193);
    let t195 = circuit_sub(in1, in80);
    let t196 = circuit_mul(t12, t195);
    let t197 = circuit_mul(t12, t194);
    let t198 = circuit_add(t197, t197);
    let t199 = circuit_sub(t196, in80);
    let t200 = circuit_mul(in57, t199);
    let t201 = circuit_sub(t198, t200);
    let t202 = circuit_add(t196, in80);
    let t203 = circuit_inverse(t202);
    let t204 = circuit_mul(t201, t203);
    let t205 = circuit_sub(in1, in79);
    let t206 = circuit_mul(t11, t205);
    let t207 = circuit_mul(t11, t204);
    let t208 = circuit_add(t207, t207);
    let t209 = circuit_sub(t206, in79);
    let t210 = circuit_mul(in56, t209);
    let t211 = circuit_sub(t208, t210);
    let t212 = circuit_add(t206, in79);
    let t213 = circuit_inverse(t212);
    let t214 = circuit_mul(t211, t213);
    let t215 = circuit_sub(in1, in78);
    let t216 = circuit_mul(t10, t215);
    let t217 = circuit_mul(t10, t214);
    let t218 = circuit_add(t217, t217);
    let t219 = circuit_sub(t216, in78);
    let t220 = circuit_mul(in55, t219);
    let t221 = circuit_sub(t218, t220);
    let t222 = circuit_add(t216, in78);
    let t223 = circuit_inverse(t222);
    let t224 = circuit_mul(t221, t223);
    let t225 = circuit_sub(in1, in77);
    let t226 = circuit_mul(t9, t225);
    let t227 = circuit_mul(t9, t224);
    let t228 = circuit_add(t227, t227);
    let t229 = circuit_sub(t226, in77);
    let t230 = circuit_mul(in54, t229);
    let t231 = circuit_sub(t228, t230);
    let t232 = circuit_add(t226, in77);
    let t233 = circuit_inverse(t232);
    let t234 = circuit_mul(t231, t233);
    let t235 = circuit_sub(in1, in76);
    let t236 = circuit_mul(t8, t235);
    let t237 = circuit_mul(t8, t234);
    let t238 = circuit_add(t237, t237);
    let t239 = circuit_sub(t236, in76);
    let t240 = circuit_mul(in53, t239);
    let t241 = circuit_sub(t238, t240);
    let t242 = circuit_add(t236, in76);
    let t243 = circuit_inverse(t242);
    let t244 = circuit_mul(t241, t243);
    let t245 = circuit_sub(in1, in75);
    let t246 = circuit_mul(t7, t245);
    let t247 = circuit_mul(t7, t244);
    let t248 = circuit_add(t247, t247);
    let t249 = circuit_sub(t246, in75);
    let t250 = circuit_mul(in52, t249);
    let t251 = circuit_sub(t248, t250);
    let t252 = circuit_add(t246, in75);
    let t253 = circuit_inverse(t252);
    let t254 = circuit_mul(t251, t253);
    let t255 = circuit_sub(in1, in74);
    let t256 = circuit_mul(t6, t255);
    let t257 = circuit_mul(t6, t254);
    let t258 = circuit_add(t257, t257);
    let t259 = circuit_sub(t256, in74);
    let t260 = circuit_mul(in51, t259);
    let t261 = circuit_sub(t258, t260);
    let t262 = circuit_add(t256, in74);
    let t263 = circuit_inverse(t262);
    let t264 = circuit_mul(t261, t263);
    let t265 = circuit_sub(in1, in73);
    let t266 = circuit_mul(t5, t265);
    let t267 = circuit_mul(t5, t264);
    let t268 = circuit_add(t267, t267);
    let t269 = circuit_sub(t266, in73);
    let t270 = circuit_mul(in50, t269);
    let t271 = circuit_sub(t268, t270);
    let t272 = circuit_add(t266, in73);
    let t273 = circuit_inverse(t272);
    let t274 = circuit_mul(t271, t273);
    let t275 = circuit_sub(in1, in72);
    let t276 = circuit_mul(t4, t275);
    let t277 = circuit_mul(t4, t274);
    let t278 = circuit_add(t277, t277);
    let t279 = circuit_sub(t276, in72);
    let t280 = circuit_mul(in49, t279);
    let t281 = circuit_sub(t278, t280);
    let t282 = circuit_add(t276, in72);
    let t283 = circuit_inverse(t282);
    let t284 = circuit_mul(t281, t283);
    let t285 = circuit_sub(in1, in71);
    let t286 = circuit_mul(t3, t285);
    let t287 = circuit_mul(t3, t284);
    let t288 = circuit_add(t287, t287);
    let t289 = circuit_sub(t286, in71);
    let t290 = circuit_mul(in48, t289);
    let t291 = circuit_sub(t288, t290);
    let t292 = circuit_add(t286, in71);
    let t293 = circuit_inverse(t292);
    let t294 = circuit_mul(t291, t293);
    let t295 = circuit_sub(in1, in70);
    let t296 = circuit_mul(t2, t295);
    let t297 = circuit_mul(t2, t294);
    let t298 = circuit_add(t297, t297);
    let t299 = circuit_sub(t296, in70);
    let t300 = circuit_mul(in47, t299);
    let t301 = circuit_sub(t298, t300);
    let t302 = circuit_add(t296, in70);
    let t303 = circuit_inverse(t302);
    let t304 = circuit_mul(t301, t303);
    let t305 = circuit_sub(in1, in69);
    let t306 = circuit_mul(t1, t305);
    let t307 = circuit_mul(t1, t304);
    let t308 = circuit_add(t307, t307);
    let t309 = circuit_sub(t306, in69);
    let t310 = circuit_mul(in46, t309);
    let t311 = circuit_sub(t308, t310);
    let t312 = circuit_add(t306, in69);
    let t313 = circuit_inverse(t312);
    let t314 = circuit_mul(t311, t313);
    let t315 = circuit_sub(in1, in68);
    let t316 = circuit_mul(t0, t315);
    let t317 = circuit_mul(t0, t314);
    let t318 = circuit_add(t317, t317);
    let t319 = circuit_sub(t316, in68);
    let t320 = circuit_mul(in45, t319);
    let t321 = circuit_sub(t318, t320);
    let t322 = circuit_add(t316, in68);
    let t323 = circuit_inverse(t322);
    let t324 = circuit_mul(t321, t323);
    let t325 = circuit_sub(in1, in67);
    let t326 = circuit_mul(in63, t325);
    let t327 = circuit_mul(in63, t324);
    let t328 = circuit_add(t327, t327);
    let t329 = circuit_sub(t326, in67);
    let t330 = circuit_mul(in44, t329);
    let t331 = circuit_sub(t328, t330);
    let t332 = circuit_add(t326, in67);
    let t333 = circuit_inverse(t332);
    let t334 = circuit_mul(t331, t333);
    let t335 = circuit_mul(t334, t15);
    let t336 = circuit_mul(in44, in66);
    let t337 = circuit_mul(t336, t17);
    let t338 = circuit_add(t335, t337);
    let t339 = circuit_mul(in66, in66);
    let t340 = circuit_sub(in65, t0);
    let t341 = circuit_inverse(t340);
    let t342 = circuit_add(in65, t0);
    let t343 = circuit_inverse(t342);
    let t344 = circuit_mul(t339, t341);
    let t345 = circuit_mul(in66, t343);
    let t346 = circuit_mul(t339, t345);
    let t347 = circuit_add(t346, t344);
    let t348 = circuit_sub(in0, t347);
    let t349 = circuit_mul(t346, in45);
    let t350 = circuit_mul(t344, t324);
    let t351 = circuit_add(t349, t350);
    let t352 = circuit_add(t338, t351);
    let t353 = circuit_mul(in66, in66);
    let t354 = circuit_mul(t339, t353);
    let t355 = circuit_sub(in65, t1);
    let t356 = circuit_inverse(t355);
    let t357 = circuit_add(in65, t1);
    let t358 = circuit_inverse(t357);
    let t359 = circuit_mul(t354, t356);
    let t360 = circuit_mul(in66, t358);
    let t361 = circuit_mul(t354, t360);
    let t362 = circuit_add(t361, t359);
    let t363 = circuit_sub(in0, t362);
    let t364 = circuit_mul(t361, in46);
    let t365 = circuit_mul(t359, t314);
    let t366 = circuit_add(t364, t365);
    let t367 = circuit_add(t352, t366);
    let t368 = circuit_mul(in66, in66);
    let t369 = circuit_mul(t354, t368);
    let t370 = circuit_sub(in65, t2);
    let t371 = circuit_inverse(t370);
    let t372 = circuit_add(in65, t2);
    let t373 = circuit_inverse(t372);
    let t374 = circuit_mul(t369, t371);
    let t375 = circuit_mul(in66, t373);
    let t376 = circuit_mul(t369, t375);
    let t377 = circuit_add(t376, t374);
    let t378 = circuit_sub(in0, t377);
    let t379 = circuit_mul(t376, in47);
    let t380 = circuit_mul(t374, t304);
    let t381 = circuit_add(t379, t380);
    let t382 = circuit_add(t367, t381);
    let t383 = circuit_mul(in66, in66);
    let t384 = circuit_mul(t369, t383);
    let t385 = circuit_sub(in65, t3);
    let t386 = circuit_inverse(t385);
    let t387 = circuit_add(in65, t3);
    let t388 = circuit_inverse(t387);
    let t389 = circuit_mul(t384, t386);
    let t390 = circuit_mul(in66, t388);
    let t391 = circuit_mul(t384, t390);
    let t392 = circuit_add(t391, t389);
    let t393 = circuit_sub(in0, t392);
    let t394 = circuit_mul(t391, in48);
    let t395 = circuit_mul(t389, t294);
    let t396 = circuit_add(t394, t395);
    let t397 = circuit_add(t382, t396);
    let t398 = circuit_mul(in66, in66);
    let t399 = circuit_mul(t384, t398);
    let t400 = circuit_sub(in65, t4);
    let t401 = circuit_inverse(t400);
    let t402 = circuit_add(in65, t4);
    let t403 = circuit_inverse(t402);
    let t404 = circuit_mul(t399, t401);
    let t405 = circuit_mul(in66, t403);
    let t406 = circuit_mul(t399, t405);
    let t407 = circuit_add(t406, t404);
    let t408 = circuit_sub(in0, t407);
    let t409 = circuit_mul(t406, in49);
    let t410 = circuit_mul(t404, t284);
    let t411 = circuit_add(t409, t410);
    let t412 = circuit_add(t397, t411);
    let t413 = circuit_mul(in66, in66);
    let t414 = circuit_mul(t399, t413);
    let t415 = circuit_sub(in65, t5);
    let t416 = circuit_inverse(t415);
    let t417 = circuit_add(in65, t5);
    let t418 = circuit_inverse(t417);
    let t419 = circuit_mul(t414, t416);
    let t420 = circuit_mul(in66, t418);
    let t421 = circuit_mul(t414, t420);
    let t422 = circuit_add(t421, t419);
    let t423 = circuit_sub(in0, t422);
    let t424 = circuit_mul(t421, in50);
    let t425 = circuit_mul(t419, t274);
    let t426 = circuit_add(t424, t425);
    let t427 = circuit_add(t412, t426);
    let t428 = circuit_mul(in66, in66);
    let t429 = circuit_mul(t414, t428);
    let t430 = circuit_sub(in65, t6);
    let t431 = circuit_inverse(t430);
    let t432 = circuit_add(in65, t6);
    let t433 = circuit_inverse(t432);
    let t434 = circuit_mul(t429, t431);
    let t435 = circuit_mul(in66, t433);
    let t436 = circuit_mul(t429, t435);
    let t437 = circuit_add(t436, t434);
    let t438 = circuit_sub(in0, t437);
    let t439 = circuit_mul(t436, in51);
    let t440 = circuit_mul(t434, t264);
    let t441 = circuit_add(t439, t440);
    let t442 = circuit_add(t427, t441);
    let t443 = circuit_mul(in66, in66);
    let t444 = circuit_mul(t429, t443);
    let t445 = circuit_sub(in65, t7);
    let t446 = circuit_inverse(t445);
    let t447 = circuit_add(in65, t7);
    let t448 = circuit_inverse(t447);
    let t449 = circuit_mul(t444, t446);
    let t450 = circuit_mul(in66, t448);
    let t451 = circuit_mul(t444, t450);
    let t452 = circuit_add(t451, t449);
    let t453 = circuit_sub(in0, t452);
    let t454 = circuit_mul(t451, in52);
    let t455 = circuit_mul(t449, t254);
    let t456 = circuit_add(t454, t455);
    let t457 = circuit_add(t442, t456);
    let t458 = circuit_mul(in66, in66);
    let t459 = circuit_mul(t444, t458);
    let t460 = circuit_sub(in65, t8);
    let t461 = circuit_inverse(t460);
    let t462 = circuit_add(in65, t8);
    let t463 = circuit_inverse(t462);
    let t464 = circuit_mul(t459, t461);
    let t465 = circuit_mul(in66, t463);
    let t466 = circuit_mul(t459, t465);
    let t467 = circuit_add(t466, t464);
    let t468 = circuit_sub(in0, t467);
    let t469 = circuit_mul(t466, in53);
    let t470 = circuit_mul(t464, t244);
    let t471 = circuit_add(t469, t470);
    let t472 = circuit_add(t457, t471);
    let t473 = circuit_mul(in66, in66);
    let t474 = circuit_mul(t459, t473);
    let t475 = circuit_sub(in65, t9);
    let t476 = circuit_inverse(t475);
    let t477 = circuit_add(in65, t9);
    let t478 = circuit_inverse(t477);
    let t479 = circuit_mul(t474, t476);
    let t480 = circuit_mul(in66, t478);
    let t481 = circuit_mul(t474, t480);
    let t482 = circuit_add(t481, t479);
    let t483 = circuit_sub(in0, t482);
    let t484 = circuit_mul(t481, in54);
    let t485 = circuit_mul(t479, t234);
    let t486 = circuit_add(t484, t485);
    let t487 = circuit_add(t472, t486);
    let t488 = circuit_mul(in66, in66);
    let t489 = circuit_mul(t474, t488);
    let t490 = circuit_sub(in65, t10);
    let t491 = circuit_inverse(t490);
    let t492 = circuit_add(in65, t10);
    let t493 = circuit_inverse(t492);
    let t494 = circuit_mul(t489, t491);
    let t495 = circuit_mul(in66, t493);
    let t496 = circuit_mul(t489, t495);
    let t497 = circuit_add(t496, t494);
    let t498 = circuit_sub(in0, t497);
    let t499 = circuit_mul(t496, in55);
    let t500 = circuit_mul(t494, t224);
    let t501 = circuit_add(t499, t500);
    let t502 = circuit_add(t487, t501);
    let t503 = circuit_mul(in66, in66);
    let t504 = circuit_mul(t489, t503);
    let t505 = circuit_sub(in65, t11);
    let t506 = circuit_inverse(t505);
    let t507 = circuit_add(in65, t11);
    let t508 = circuit_inverse(t507);
    let t509 = circuit_mul(t504, t506);
    let t510 = circuit_mul(in66, t508);
    let t511 = circuit_mul(t504, t510);
    let t512 = circuit_add(t511, t509);
    let t513 = circuit_sub(in0, t512);
    let t514 = circuit_mul(t511, in56);
    let t515 = circuit_mul(t509, t214);
    let t516 = circuit_add(t514, t515);
    let t517 = circuit_add(t502, t516);
    let t518 = circuit_mul(in66, in66);
    let t519 = circuit_mul(t504, t518);
    let t520 = circuit_sub(in65, t12);
    let t521 = circuit_inverse(t520);
    let t522 = circuit_add(in65, t12);
    let t523 = circuit_inverse(t522);
    let t524 = circuit_mul(t519, t521);
    let t525 = circuit_mul(in66, t523);
    let t526 = circuit_mul(t519, t525);
    let t527 = circuit_add(t526, t524);
    let t528 = circuit_sub(in0, t527);
    let t529 = circuit_mul(t526, in57);
    let t530 = circuit_mul(t524, t204);
    let t531 = circuit_add(t529, t530);
    let t532 = circuit_add(t517, t531);
    let t533 = circuit_mul(in66, in66);
    let t534 = circuit_mul(t519, t533);
    let t535 = circuit_sub(in65, t13);
    let t536 = circuit_inverse(t535);
    let t537 = circuit_add(in65, t13);
    let t538 = circuit_inverse(t537);
    let t539 = circuit_mul(t534, t536);
    let t540 = circuit_mul(in66, t538);
    let t541 = circuit_mul(t534, t540);
    let t542 = circuit_add(t541, t539);
    let t543 = circuit_sub(in0, t542);
    let t544 = circuit_mul(t541, in58);
    let t545 = circuit_mul(t539, t194);
    let t546 = circuit_add(t544, t545);
    let t547 = circuit_add(t532, t546);
    let t548 = circuit_mul(in66, in66);
    let t549 = circuit_mul(t534, t548);
    let t550 = circuit_mul(in66, in66);
    let t551 = circuit_mul(t549, t550);
    let t552 = circuit_mul(in66, in66);
    let t553 = circuit_mul(t551, t552);
    let t554 = circuit_mul(in66, in66);
    let t555 = circuit_mul(t553, t554);
    let t556 = circuit_mul(in66, in66);
    let t557 = circuit_mul(t555, t556);
    let t558 = circuit_mul(in66, in66);
    let t559 = circuit_mul(t557, t558);
    let t560 = circuit_mul(in66, in66);
    let t561 = circuit_mul(t559, t560);
    let t562 = circuit_mul(in66, in66);
    let t563 = circuit_mul(t561, t562);
    let t564 = circuit_mul(in66, in66);
    let t565 = circuit_mul(t563, t564);
    let t566 = circuit_mul(in66, in66);
    let t567 = circuit_mul(t565, t566);
    let t568 = circuit_mul(in66, in66);
    let t569 = circuit_mul(t567, t568);
    let t570 = circuit_mul(in66, in66);
    let t571 = circuit_mul(t569, t570);
    let t572 = circuit_mul(in66, in66);
    let t573 = circuit_mul(t571, t572);
    let t574 = circuit_mul(in66, in66);
    let t575 = circuit_mul(t573, t574);
    let t576 = circuit_sub(in65, in63);
    let t577 = circuit_inverse(t576);
    let t578 = circuit_mul(in1, t577);
    let t579 = circuit_mul(in2, in63);
    let t580 = circuit_sub(in65, t579);
    let t581 = circuit_inverse(t580);
    let t582 = circuit_mul(in1, t581);
    let t583 = circuit_mul(in66, in66);
    let t584 = circuit_mul(t575, t583);
    let t585 = circuit_mul(t578, t584);
    let t586 = circuit_sub(in0, t585);
    let t587 = circuit_mul(t584, in66);
    let t588 = circuit_mul(t585, in59);
    let t589 = circuit_add(t547, t588);
    let t590 = circuit_mul(t582, t587);
    let t591 = circuit_sub(in0, t590);
    let t592 = circuit_mul(t587, in66);
    let t593 = circuit_mul(t590, in60);
    let t594 = circuit_add(t589, t593);
    let t595 = circuit_mul(t578, t592);
    let t596 = circuit_sub(in0, t595);
    let t597 = circuit_mul(t592, in66);
    let t598 = circuit_mul(t595, in61);
    let t599 = circuit_add(t594, t598);
    let t600 = circuit_mul(t578, t597);
    let t601 = circuit_sub(in0, t600);
    let t602 = circuit_mul(t600, in62);
    let t603 = circuit_add(t599, t602);
    let t604 = circuit_add(t591, t596);
    let t605 = circuit_add(t134, t166);
    let t606 = circuit_add(t138, t170);
    let t607 = circuit_add(t142, t174);
    let t608 = circuit_add(t146, t178);
    let t609 = circuit_add(t150, t182);

    let modulus = modulus;

    let mut circuit_inputs = (
        t20,
        t26,
        t30,
        t34,
        t38,
        t42,
        t46,
        t50,
        t54,
        t58,
        t62,
        t66,
        t70,
        t74,
        t78,
        t82,
        t86,
        t90,
        t94,
        t98,
        t102,
        t106,
        t110,
        t114,
        t118,
        t122,
        t126,
        t130,
        t605,
        t606,
        t607,
        t608,
        t609,
        t154,
        t158,
        t162,
        t348,
        t363,
        t378,
        t393,
        t408,
        t423,
        t438,
        t453,
        t468,
        t483,
        t498,
        t513,
        t528,
        t543,
        t586,
        t604,
        t601,
        t603,
    )
        .new_inputs();
    // Prefill constants:
    circuit_inputs = circuit_inputs.next_2([0x0, 0x0, 0x0, 0x0]); // in0
    circuit_inputs = circuit_inputs.next_2([0x1, 0x0, 0x0, 0x0]); // in1
    circuit_inputs = circuit_inputs
        .next_2(
            [0x6750f230c893619174a57a76, 0xf086204a9f36ffb061794254, 0x7b0c561a6148404, 0x0],
        ); // in2
    // Fill inputs:

    for val in p_sumcheck_evaluations {
        circuit_inputs = circuit_inputs.next_u256(*val);
    } // in3 - in42

    circuit_inputs = circuit_inputs.next_2(p_gemini_masking_eval); // in43

    for val in p_gemini_a_evaluations {
        circuit_inputs = circuit_inputs.next_u256(*val);
    } // in44 - in58

    for val in p_libra_poly_evals {
        circuit_inputs = circuit_inputs.next_u256(*val);
    } // in59 - in62

    circuit_inputs = circuit_inputs.next_2(tp_gemini_r); // in63
    circuit_inputs = circuit_inputs.next_2(tp_rho); // in64
    circuit_inputs = circuit_inputs.next_2(tp_shplonk_z); // in65
    circuit_inputs = circuit_inputs.next_2(tp_shplonk_nu); // in66

    for val in tp_sum_check_u_challenges {
        circuit_inputs = circuit_inputs.next_u128(*val);
    } // in67 - in81

    let outputs = circuit_inputs.done_2().eval(modulus).unwrap();
    let scalar_1: u384 = outputs.get_output(t20);
    let scalar_2: u384 = outputs.get_output(t26);
    let scalar_3: u384 = outputs.get_output(t30);
    let scalar_4: u384 = outputs.get_output(t34);
    let scalar_5: u384 = outputs.get_output(t38);
    let scalar_6: u384 = outputs.get_output(t42);
    let scalar_7: u384 = outputs.get_output(t46);
    let scalar_8: u384 = outputs.get_output(t50);
    let scalar_9: u384 = outputs.get_output(t54);
    let scalar_10: u384 = outputs.get_output(t58);
    let scalar_11: u384 = outputs.get_output(t62);
    let scalar_12: u384 = outputs.get_output(t66);
    let scalar_13: u384 = outputs.get_output(t70);
    let scalar_14: u384 = outputs.get_output(t74);
    let scalar_15: u384 = outputs.get_output(t78);
    let scalar_16: u384 = outputs.get_output(t82);
    let scalar_17: u384 = outputs.get_output(t86);
    let scalar_18: u384 = outputs.get_output(t90);
    let scalar_19: u384 = outputs.get_output(t94);
    let scalar_20: u384 = outputs.get_output(t98);
    let scalar_21: u384 = outputs.get_output(t102);
    let scalar_22: u384 = outputs.get_output(t106);
    let scalar_23: u384 = outputs.get_output(t110);
    let scalar_24: u384 = outputs.get_output(t114);
    let scalar_25: u384 = outputs.get_output(t118);
    let scalar_26: u384 = outputs.get_output(t122);
    let scalar_27: u384 = outputs.get_output(t126);
    let scalar_28: u384 = outputs.get_output(t130);
    let scalar_29: u384 = outputs.get_output(t605);
    let scalar_30: u384 = outputs.get_output(t606);
    let scalar_31: u384 = outputs.get_output(t607);
    let scalar_32: u384 = outputs.get_output(t608);
    let scalar_33: u384 = outputs.get_output(t609);
    let scalar_34: u384 = outputs.get_output(t154);
    let scalar_35: u384 = outputs.get_output(t158);
    let scalar_36: u384 = outputs.get_output(t162);
    let scalar_42: u384 = outputs.get_output(t348);
    let scalar_43: u384 = outputs.get_output(t363);
    let scalar_44: u384 = outputs.get_output(t378);
    let scalar_45: u384 = outputs.get_output(t393);
    let scalar_46: u384 = outputs.get_output(t408);
    let scalar_47: u384 = outputs.get_output(t423);
    let scalar_48: u384 = outputs.get_output(t438);
    let scalar_49: u384 = outputs.get_output(t453);
    let scalar_50: u384 = outputs.get_output(t468);
    let scalar_51: u384 = outputs.get_output(t483);
    let scalar_52: u384 = outputs.get_output(t498);
    let scalar_53: u384 = outputs.get_output(t513);
    let scalar_54: u384 = outputs.get_output(t528);
    let scalar_55: u384 = outputs.get_output(t543);
    let scalar_69: u384 = outputs.get_output(t586);
    let scalar_70: u384 = outputs.get_output(t604);
    let scalar_71: u384 = outputs.get_output(t601);
    let scalar_72: u384 = outputs.get_output(t603);
    return (
        scalar_1,
        scalar_2,
        scalar_3,
        scalar_4,
        scalar_5,
        scalar_6,
        scalar_7,
        scalar_8,
        scalar_9,
        scalar_10,
        scalar_11,
        scalar_12,
        scalar_13,
        scalar_14,
        scalar_15,
        scalar_16,
        scalar_17,
        scalar_18,
        scalar_19,
        scalar_20,
        scalar_21,
        scalar_22,
        scalar_23,
        scalar_24,
        scalar_25,
        scalar_26,
        scalar_27,
        scalar_28,
        scalar_29,
        scalar_30,
        scalar_31,
        scalar_32,
        scalar_33,
        scalar_34,
        scalar_35,
        scalar_36,
        scalar_42,
        scalar_43,
        scalar_44,
        scalar_45,
        scalar_46,
        scalar_47,
        scalar_48,
        scalar_49,
        scalar_50,
        scalar_51,
        scalar_52,
        scalar_53,
        scalar_54,
        scalar_55,
        scalar_69,
        scalar_70,
        scalar_71,
        scalar_72,
    );
}
#[inline(always)]
pub fn run_GRUMPKIN_ZK_HONK_EVALS_CONS_INIT_SIZE_15_circuit(
    tp_gemini_r: u384, modulus: CircuitModulus,
) -> (u384, u384) {
    // CONSTANT stack
    let in0 = CE::<CI<0>> {}; // 0x1
    let in1 = CE::<CI<1>> {}; // 0x204bd3277422fad364751ad938e2b5e6a54cf8c68712848a692c553d0329f5d6

    // INPUT stack
    let in2 = CE::<CI<2>> {};
    let t0 = circuit_sub(in2, in0);
    let t1 = circuit_inverse(t0);
    let t2 = circuit_mul(in1, in2);

    let modulus = modulus;

    let mut circuit_inputs = (t1, t2).new_inputs();
    // Prefill constants:
    circuit_inputs = circuit_inputs.next_2([0x1, 0x0, 0x0, 0x0]); // in0
    circuit_inputs = circuit_inputs
        .next_2(
            [0x8712848a692c553d0329f5d6, 0x64751ad938e2b5e6a54cf8c6, 0x204bd3277422fad3, 0x0],
        ); // in1
    // Fill inputs:
    circuit_inputs = circuit_inputs.next_2(tp_gemini_r); // in2

    let outputs = circuit_inputs.done_2().eval(modulus).unwrap();
    let challenge_poly_eval: u384 = outputs.get_output(t1);
    let root_power_times_tp_gemini_r: u384 = outputs.get_output(t2);
    return (challenge_poly_eval, root_power_times_tp_gemini_r);
}
#[inline(always)]
pub fn run_GRUMPKIN_ZK_HONK_EVALS_CONS_LOOP_SIZE_15_circuit(
    challenge_poly_eval: u384,
    root_power_times_tp_gemini_r: u384,
    tp_sumcheck_u_challenge: u384,
    modulus: CircuitModulus,
) -> (u384, u384) {
    // CONSTANT stack
    let in0 = CE::<CI<0>> {}; // 0x1
    let in1 = CE::<CI<1>> {}; // 0x204bd3277422fad364751ad938e2b5e6a54cf8c68712848a692c553d0329f5d6

    // INPUT stack
    let (in2, in3, in4) = (CE::<CI<2>> {}, CE::<CI<3>> {}, CE::<CI<4>> {});
    let t0 = circuit_sub(in3, in0);
    let t1 = circuit_inverse(t0);
    let t2 = circuit_mul(in0, t1);
    let t3 = circuit_add(in2, t2);
    let t4 = circuit_mul(in3, in1);
    let t5 = circuit_mul(in0, in4);
    let t6 = circuit_sub(t4, in0);
    let t7 = circuit_inverse(t6);
    let t8 = circuit_mul(t5, t7);
    let t9 = circuit_add(t3, t8);
    let t10 = circuit_mul(t4, in1);
    let t11 = circuit_mul(t5, in4);
    let t12 = circuit_sub(t10, in0);
    let t13 = circuit_inverse(t12);
    let t14 = circuit_mul(t11, t13);
    let t15 = circuit_add(t9, t14);
    let t16 = circuit_mul(t10, in1);
    let t17 = circuit_mul(t11, in4);
    let t18 = circuit_sub(t16, in0);
    let t19 = circuit_inverse(t18);
    let t20 = circuit_mul(t17, t19);
    let t21 = circuit_add(t15, t20);
    let t22 = circuit_mul(t16, in1);
    let t23 = circuit_mul(t17, in4);
    let t24 = circuit_sub(t22, in0);
    let t25 = circuit_inverse(t24);
    let t26 = circuit_mul(t23, t25);
    let t27 = circuit_add(t21, t26);
    let t28 = circuit_mul(t22, in1);
    let t29 = circuit_mul(t23, in4);
    let t30 = circuit_sub(t28, in0);
    let t31 = circuit_inverse(t30);
    let t32 = circuit_mul(t29, t31);
    let t33 = circuit_add(t27, t32);
    let t34 = circuit_mul(t28, in1);
    let t35 = circuit_mul(t29, in4);
    let t36 = circuit_sub(t34, in0);
    let t37 = circuit_inverse(t36);
    let t38 = circuit_mul(t35, t37);
    let t39 = circuit_add(t33, t38);
    let t40 = circuit_mul(t34, in1);
    let t41 = circuit_mul(t35, in4);
    let t42 = circuit_sub(t40, in0);
    let t43 = circuit_inverse(t42);
    let t44 = circuit_mul(t41, t43);
    let t45 = circuit_add(t39, t44);
    let t46 = circuit_mul(t40, in1);
    let t47 = circuit_mul(t41, in4);
    let t48 = circuit_sub(t46, in0);
    let t49 = circuit_inverse(t48);
    let t50 = circuit_mul(t47, t49);
    let t51 = circuit_add(t45, t50);
    let t52 = circuit_mul(t46, in1);

    let modulus = modulus;

    let mut circuit_inputs = (t51, t52).new_inputs();
    // Prefill constants:
    circuit_inputs = circuit_inputs.next_2([0x1, 0x0, 0x0, 0x0]); // in0
    circuit_inputs = circuit_inputs
        .next_2(
            [0x8712848a692c553d0329f5d6, 0x64751ad938e2b5e6a54cf8c6, 0x204bd3277422fad3, 0x0],
        ); // in1
    // Fill inputs:
    circuit_inputs = circuit_inputs.next_2(challenge_poly_eval); // in2
    circuit_inputs = circuit_inputs.next_2(root_power_times_tp_gemini_r); // in3
    circuit_inputs = circuit_inputs.next_2(tp_sumcheck_u_challenge); // in4

    let outputs = circuit_inputs.done_2().eval(modulus).unwrap();
    let challenge_poly_eval: u384 = outputs.get_output(t51);
    let root_power_times_tp_gemini_r: u384 = outputs.get_output(t52);
    return (challenge_poly_eval, root_power_times_tp_gemini_r);
}
#[inline(always)]
pub fn run_GRUMPKIN_ZK_HONK_EVALS_CONS_DONE_SIZE_15_circuit(
    p_libra_evaluation: u384,
    p_libra_poly_evals: Span<u256>,
    tp_gemini_r: u384,
    challenge_poly_eval: u384,
    root_power_times_tp_gemini_r: u384,
    modulus: CircuitModulus,
) -> (u384, u384) {
    // CONSTANT stack
    let in0 = CE::<CI<0>> {}; // 0x204bd3277422fad364751ad938e2b5e6a54cf8c68712848a692c553d0329f5d6
    let in1 = CE::<CI<1>> {}; // 0x1
    let in2 = CE::<CI<2>> {}; // 0x3033ea246e506e898e97f570caffd704cb0bb460313fb720b29e139e5c100001

    // INPUT stack
    let (in3, in4, in5) = (CE::<CI<3>> {}, CE::<CI<4>> {}, CE::<CI<5>> {});
    let (in6, in7, in8) = (CE::<CI<6>> {}, CE::<CI<7>> {}, CE::<CI<8>> {});
    let (in9, in10) = (CE::<CI<9>> {}, CE::<CI<10>> {});
    let t0 = circuit_mul(in10, in0);
    let t1 = circuit_mul(t0, in0);
    let t2 = circuit_sub(in8, in1);
    let t3 = circuit_inverse(t2);
    let t4 = circuit_sub(t1, in1);
    let t5 = circuit_inverse(t4);
    let t6 = circuit_mul(in8, in8);
    let t7 = circuit_mul(t6, t6);
    let t8 = circuit_mul(t7, t7);
    let t9 = circuit_mul(t8, t8);
    let t10 = circuit_mul(t9, t9);
    let t11 = circuit_mul(t10, t10);
    let t12 = circuit_mul(t11, t11);
    let t13 = circuit_mul(t12, t12);
    let t14 = circuit_sub(t13, in1);
    let t15 = circuit_mul(t14, in2);
    let t16 = circuit_mul(in9, t15);
    let t17 = circuit_mul(t3, t15);
    let t18 = circuit_mul(t5, t15);
    let t19 = circuit_mul(t17, in6);
    let t20 = circuit_sub(in8, in0);
    let t21 = circuit_sub(in5, in6);
    let t22 = circuit_mul(in4, t16);
    let t23 = circuit_sub(t21, t22);
    let t24 = circuit_mul(t20, t23);
    let t25 = circuit_add(t19, t24);
    let t26 = circuit_sub(in6, in3);
    let t27 = circuit_mul(t18, t26);
    let t28 = circuit_add(t25, t27);
    let t29 = circuit_mul(t14, in7);
    let t30 = circuit_sub(t28, t29);

    let modulus = modulus;

    let mut circuit_inputs = (t14, t30).new_inputs();
    // Prefill constants:
    circuit_inputs = circuit_inputs
        .next_2(
            [0x8712848a692c553d0329f5d6, 0x64751ad938e2b5e6a54cf8c6, 0x204bd3277422fad3, 0x0],
        ); // in0
    circuit_inputs = circuit_inputs.next_2([0x1, 0x0, 0x0, 0x0]); // in1
    circuit_inputs = circuit_inputs
        .next_2(
            [0x313fb720b29e139e5c100001, 0x8e97f570caffd704cb0bb460, 0x3033ea246e506e89, 0x0],
        ); // in2
    // Fill inputs:
    circuit_inputs = circuit_inputs.next_2(p_libra_evaluation); // in3

    for val in p_libra_poly_evals {
        circuit_inputs = circuit_inputs.next_u256(*val);
    } // in4 - in7

    circuit_inputs = circuit_inputs.next_2(tp_gemini_r); // in8
    circuit_inputs = circuit_inputs.next_2(challenge_poly_eval); // in9
    circuit_inputs = circuit_inputs.next_2(root_power_times_tp_gemini_r); // in10

    let outputs = circuit_inputs.done_2().eval(modulus).unwrap();
    let vanishing_check: u384 = outputs.get_output(t14);
    let diff_check: u384 = outputs.get_output(t30);
    return (vanishing_check, diff_check);
}

impl CircuitDefinition54<
    E0,
    E1,
    E2,
    E3,
    E4,
    E5,
    E6,
    E7,
    E8,
    E9,
    E10,
    E11,
    E12,
    E13,
    E14,
    E15,
    E16,
    E17,
    E18,
    E19,
    E20,
    E21,
    E22,
    E23,
    E24,
    E25,
    E26,
    E27,
    E28,
    E29,
    E30,
    E31,
    E32,
    E33,
    E34,
    E35,
    E36,
    E37,
    E38,
    E39,
    E40,
    E41,
    E42,
    E43,
    E44,
    E45,
    E46,
    E47,
    E48,
    E49,
    E50,
    E51,
    E52,
    E53,
> of core::circuit::CircuitDefinition<
    (
        CE<E0>,
        CE<E1>,
        CE<E2>,
        CE<E3>,
        CE<E4>,
        CE<E5>,
        CE<E6>,
        CE<E7>,
        CE<E8>,
        CE<E9>,
        CE<E10>,
        CE<E11>,
        CE<E12>,
        CE<E13>,
        CE<E14>,
        CE<E15>,
        CE<E16>,
        CE<E17>,
        CE<E18>,
        CE<E19>,
        CE<E20>,
        CE<E21>,
        CE<E22>,
        CE<E23>,
        CE<E24>,
        CE<E25>,
        CE<E26>,
        CE<E27>,
        CE<E28>,
        CE<E29>,
        CE<E30>,
        CE<E31>,
        CE<E32>,
        CE<E33>,
        CE<E34>,
        CE<E35>,
        CE<E36>,
        CE<E37>,
        CE<E38>,
        CE<E39>,
        CE<E40>,
        CE<E41>,
        CE<E42>,
        CE<E43>,
        CE<E44>,
        CE<E45>,
        CE<E46>,
        CE<E47>,
        CE<E48>,
        CE<E49>,
        CE<E50>,
        CE<E51>,
        CE<E52>,
        CE<E53>,
    ),
> {
    type CircuitType =
        core::circuit::Circuit<
            (
                E0,
                E1,
                E2,
                E3,
                E4,
                E5,
                E6,
                E7,
                E8,
                E9,
                E10,
                E11,
                E12,
                E13,
                E14,
                E15,
                E16,
                E17,
                E18,
                E19,
                E20,
                E21,
                E22,
                E23,
                E24,
                E25,
                E26,
                E27,
                E28,
                E29,
                E30,
                E31,
                E32,
                E33,
                E34,
                E35,
                E36,
                E37,
                E38,
                E39,
                E40,
                E41,
                E42,
                E43,
                E44,
                E45,
                E46,
                E47,
                E48,
                E49,
                E50,
                E51,
                E52,
                E53,
            ),
        >;
}
impl MyDrp_54<
    E0,
    E1,
    E2,
    E3,
    E4,
    E5,
    E6,
    E7,
    E8,
    E9,
    E10,
    E11,
    E12,
    E13,
    E14,
    E15,
    E16,
    E17,
    E18,
    E19,
    E20,
    E21,
    E22,
    E23,
    E24,
    E25,
    E26,
    E27,
    E28,
    E29,
    E30,
    E31,
    E32,
    E33,
    E34,
    E35,
    E36,
    E37,
    E38,
    E39,
    E40,
    E41,
    E42,
    E43,
    E44,
    E45,
    E46,
    E47,
    E48,
    E49,
    E50,
    E51,
    E52,
    E53,
> of Drop<
    (
        CE<E0>,
        CE<E1>,
        CE<E2>,
        CE<E3>,
        CE<E4>,
        CE<E5>,
        CE<E6>,
        CE<E7>,
        CE<E8>,
        CE<E9>,
        CE<E10>,
        CE<E11>,
        CE<E12>,
        CE<E13>,
        CE<E14>,
        CE<E15>,
        CE<E16>,
        CE<E17>,
        CE<E18>,
        CE<E19>,
        CE<E20>,
        CE<E21>,
        CE<E22>,
        CE<E23>,
        CE<E24>,
        CE<E25>,
        CE<E26>,
        CE<E27>,
        CE<E28>,
        CE<E29>,
        CE<E30>,
        CE<E31>,
        CE<E32>,
        CE<E33>,
        CE<E34>,
        CE<E35>,
        CE<E36>,
        CE<E37>,
        CE<E38>,
        CE<E39>,
        CE<E40>,
        CE<E41>,
        CE<E42>,
        CE<E43>,
        CE<E44>,
        CE<E45>,
        CE<E46>,
        CE<E47>,
        CE<E48>,
        CE<E49>,
        CE<E50>,
        CE<E51>,
        CE<E52>,
        CE<E53>,
    ),
>;

#[inline(never)]
pub fn is_on_curve_bn254(p: G1Point, modulus: CircuitModulus) -> bool {
    // INPUT stack
    // y^2 = x^3 + 3
    let (in0, in1) = (CE::<CI<0>> {}, CE::<CI<1>> {});
    let y2 = circuit_mul(in1, in1);
    let x2 = circuit_mul(in0, in0);
    let x3 = circuit_mul(in0, x2);
    let y2_minus_x3 = circuit_sub(y2, x3);

    let mut circuit_inputs = (y2_minus_x3,).new_inputs();
    // Prefill constants:

    // Fill inputs:
    circuit_inputs = circuit_inputs.next_2(p.x); // in0
    circuit_inputs = circuit_inputs.next_2(p.y); // in1

    let outputs = circuit_inputs.done_2().eval(modulus).unwrap();
    let zero_check: u384 = outputs.get_output(y2_minus_x3);
    return zero_check == u384 { limb0: 3, limb1: 0, limb2: 0, limb3: 0 };
}

