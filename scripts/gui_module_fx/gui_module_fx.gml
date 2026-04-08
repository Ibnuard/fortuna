function GuiModuleFx(_ctrl) constructor {
    ctrl = _ctrl;
    
    dice_particles = [];

    static step = function() {
        for (var _i = array_length(dice_particles) - 1; _i >= 0; _i--) {
            var _p = dice_particles[_i];
            _p.gui_x     += _p.vel_x;
            _p.gui_y     += _p.vel_y;
            _p.vel_y     += _p.gravity;
            _p.life--;
            if (_p.life <= 0) {
                array_delete(dice_particles, _i, 1);
            }
        }
    }

    static draw_vignette = function() {
        var _gui_w = display_get_gui_width();
        var _gui_h = display_get_gui_height();
        if (shader_is_compiled(shd_vignette)) {
            gpu_set_blendmode(bm_normal); 
            //shader_set(shd_vignette);
            //var _u_res = shader_get_uniform(shd_vignette, "u_resolution");
            //
            //shader_set_uniform_f(_u_res, _gui_w, _gui_h);
            //
            //draw_rectangle_color(0, 0, _gui_w, _gui_h, c_black, c_black, c_black, c_black, false);
            //shader_reset();
        }
    }

    static draw_scanline = function() {
        if (shader_is_compiled(shd_scanline)) {
            gpu_set_blendmode(bm_normal);
            shader_set(shd_scanline);
            var _u_res = shader_get_uniform(shd_scanline, "u_resolution");
            
            shader_set_uniform_f(_u_res, display_get_gui_width(), display_get_gui_height());
            
            draw_rectangle_color(0, 0, display_get_gui_width(), display_get_gui_height(), c_black, c_black, c_black, c_black, false);
            shader_reset();
        }
    }

    static draw_particles = function() {
        var _pcount = array_length(dice_particles);
        if (_pcount > 0) {
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            for (var _i = 0; _i < _pcount; _i++) {
                var _p = dice_particles[_i];
                var _alpha = clamp(_p.life / _p.life_max, 0, 1);
                draw_set_alpha(_alpha);
                draw_sprite_part(_p.spr, _p.sub_img, _p.chunk_xx, _p.chunk_yy, _p.chunk_sz, _p.chunk_sz, _p.gui_x, _p.gui_y);
            }
            draw_set_alpha(1.0);
        }
        
        if (ctrl.mod_dice.dice_flash_alpha > 0) {
            draw_set_color(c_white);
            draw_set_alpha(ctrl.mod_dice.dice_flash_alpha);
            draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
            draw_set_alpha(1.0);
        }
    }
}