/* @ds-bundle: {"format":4,"namespace":"MySerialDesignSystem_514ab4","components":[{"name":"Avatar","sourcePath":"components/core/Avatar.jsx"},{"name":"Badge","sourcePath":"components/core/Badge.jsx"},{"name":"Button","sourcePath":"components/core/Button.jsx"},{"name":"Chip","sourcePath":"components/core/Chip.jsx"},{"name":"IconButton","sourcePath":"components/core/IconButton.jsx"},{"name":"Sheet","sourcePath":"components/feedback/Sheet.jsx"},{"name":"Toast","sourcePath":"components/feedback/Toast.jsx"},{"name":"Checkbox","sourcePath":"components/forms/Checkbox.jsx"},{"name":"Input","sourcePath":"components/forms/Input.jsx"},{"name":"SearchField","sourcePath":"components/forms/SearchField.jsx"},{"name":"SegmentedControl","sourcePath":"components/forms/SegmentedControl.jsx"},{"name":"Switch","sourcePath":"components/forms/Switch.jsx"},{"name":"EpisodeRow","sourcePath":"components/media/EpisodeRow.jsx"},{"name":"PosterCard","sourcePath":"components/media/PosterCard.jsx"},{"name":"PosterPlaceholder","sourcePath":"components/media/PosterPlaceholder.jsx"},{"name":"ProgressBar","sourcePath":"components/media/ProgressBar.jsx"},{"name":"ProgressRing","sourcePath":"components/media/ProgressRing.jsx"},{"name":"RatingHistogram","sourcePath":"components/media/RatingHistogram.jsx"},{"name":"RatingStars","sourcePath":"components/media/RatingStars.jsx"},{"name":"BottomNav","sourcePath":"components/navigation/BottomNav.jsx"},{"name":"TopBar","sourcePath":"components/navigation/TopBar.jsx"}],"sourceHashes":{"components/core/Avatar.jsx":"3dfc8cf766d9","components/core/Badge.jsx":"c1b3a2660da4","components/core/Button.jsx":"9f0dbf85d795","components/core/Chip.jsx":"1618b29c3537","components/core/IconButton.jsx":"fbece3074cc0","components/feedback/Sheet.jsx":"15867e4a49a1","components/feedback/Toast.jsx":"4d32068baab2","components/forms/Checkbox.jsx":"e2d995be1295","components/forms/Input.jsx":"6d3127d9da01","components/forms/SearchField.jsx":"9ca1e7d25dd1","components/forms/SegmentedControl.jsx":"aa7e116fd249","components/forms/Switch.jsx":"97ab2cd37874","components/media/EpisodeRow.jsx":"9cc44696dc1b","components/media/PosterCard.jsx":"7978be46f825","components/media/PosterPlaceholder.jsx":"4c9543662ded","components/media/ProgressBar.jsx":"0db9060f7749","components/media/ProgressRing.jsx":"17589b4db7a5","components/media/RatingHistogram.jsx":"1f70e9758f36","components/media/RatingStars.jsx":"36bf8a5e3a8d","components/navigation/BottomNav.jsx":"7aa3e91b18b6","components/navigation/TopBar.jsx":"d832311c00ba","ui_kits/myserial-app/DiaryScreen.jsx":"c40d613f7d51","ui_kits/myserial-app/HomeScreen.jsx":"7ac08528b207","ui_kits/myserial-app/ProfileScreen.jsx":"b71038f48016","ui_kits/myserial-app/SearchScreen.jsx":"14145c2bc7c7","ui_kits/myserial-app/ShowScreen.jsx":"33f5225f2af3","ui_kits/myserial-app/data.js":"3f27c08aa505"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.MySerialDesignSystem_514ab4 = window.MySerialDesignSystem_514ab4 || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/core/Avatar.jsx
try { (() => {
const PALETTE = ['#FF5C38', '#3DD68C', '#4CB8FF', '#FFB43A', '#B48CFF'];
function Avatar({
  name = '',
  src,
  size = 40,
  ring = false,
  style
}) {
  const initials = name.split(/\s+/).map(w => w[0]).slice(0, 2).join('').toUpperCase();
  const bg = PALETTE[(name.charCodeAt(0) || 0) % PALETTE.length];
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: size,
      height: size,
      borderRadius: 'var(--r-pill)',
      overflow: 'hidden',
      flexShrink: 0,
      background: src ? 'var(--surface-pressed)' : bg,
      color: '#fff',
      fontFamily: 'var(--font-display)',
      fontWeight: 700,
      fontSize: size * .38,
      boxShadow: ring ? '0 0 0 2px var(--bg-app),0 0 0 4px var(--signal)' : undefined,
      ...style
    }
  }, src ? /*#__PURE__*/React.createElement("img", {
    src: src,
    alt: name,
    style: {
      width: '100%',
      height: '100%',
      objectFit: 'cover'
    }
  }) : initials);
}
Object.assign(__ds_scope, { Avatar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Avatar.jsx", error: String((e && e.message) || e) }); }

// components/core/Badge.jsx
try { (() => {
const V = {
  signal: {
    background: 'var(--signal)',
    color: '#fff'
  },
  track: {
    background: 'var(--track)',
    color: '#0C1014'
  },
  neutral: {
    background: 'var(--surface-pressed)',
    color: 'var(--text-muted)'
  },
  outline: {
    background: 'transparent',
    color: 'var(--text-muted)',
    border: '1px solid var(--border-hairline)'
  }
};
function Badge({
  variant = 'neutral',
  children,
  style
}) {
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      height: 20,
      padding: '0 8px',
      borderRadius: 6,
      fontFamily: 'var(--font-body)',
      fontSize: 'var(--type-micro)',
      fontWeight: 700,
      letterSpacing: 'var(--track-overline)',
      textTransform: 'uppercase',
      ...V[variant],
      ...style
    }
  }, children);
}
Object.assign(__ds_scope, { Badge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Badge.jsx", error: String((e && e.message) || e) }); }

// components/core/Button.jsx
try { (() => {
const V = {
  primary: {
    background: 'var(--signal)',
    color: '#fff',
    border: 'none'
  },
  secondary: {
    background: 'var(--surface-raised)',
    color: 'var(--text-body)',
    border: '1px solid var(--border-hairline)'
  },
  ghost: {
    background: 'transparent',
    color: 'var(--text-body)',
    border: 'none'
  },
  danger: {
    background: 'var(--alert)',
    color: '#fff',
    border: 'none'
  },
  glass: {
    background: 'rgba(255,255,255,.16)',
    color: '#fff',
    border: 'none',
    backdropFilter: 'blur(12px)',
    WebkitBackdropFilter: 'blur(12px)'
  }
};
const S = {
  sm: {
    height: 36,
    padding: '0 14px',
    fontSize: 13
  },
  md: {
    height: 44,
    padding: '0 20px',
    fontSize: 15
  },
  lg: {
    height: 52,
    padding: '0 26px',
    fontSize: 16
  }
};
function Button({
  variant = 'primary',
  size = 'md',
  disabled = false,
  fullWidth = false,
  icon,
  children,
  onClick,
  style
}) {
  return /*#__PURE__*/React.createElement("button", {
    onClick: disabled ? undefined : onClick,
    disabled: disabled,
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 8,
      borderRadius: 'var(--r-pill)',
      fontFamily: 'var(--font-body)',
      fontWeight: 600,
      cursor: disabled ? 'default' : 'pointer',
      opacity: disabled ? .45 : 1,
      width: fullWidth ? '100%' : undefined,
      whiteSpace: 'nowrap',
      transition: 'transform var(--dur-fast) var(--ease-out),background var(--dur-fast)',
      ...V[variant],
      ...S[size],
      ...style
    },
    onPointerDown: e => {
      if (!disabled) e.currentTarget.style.transform = 'scale(var(--press-scale))';
    },
    onPointerUp: e => {
      e.currentTarget.style.transform = '';
    },
    onPointerLeave: e => {
      e.currentTarget.style.transform = '';
    }
  }, icon, children);
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Button.jsx", error: String((e && e.message) || e) }); }

// components/core/Chip.jsx
try { (() => {
function Chip({
  selected = false,
  icon,
  children,
  onClick,
  style
}) {
  return /*#__PURE__*/React.createElement("button", {
    onClick: onClick,
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 6,
      height: 34,
      padding: '0 14px',
      borderRadius: 'var(--r-pill)',
      fontFamily: 'var(--font-body)',
      fontSize: 13,
      fontWeight: 500,
      cursor: 'pointer',
      background: selected ? 'var(--signal-soft)' : 'var(--surface-raised)',
      color: selected ? 'var(--signal)' : 'var(--text-body)',
      border: selected ? '1px solid var(--signal)' : '1px solid var(--border-hairline)',
      transition: 'background var(--dur-fast),color var(--dur-fast)',
      ...style
    }
  }, icon, children);
}
Object.assign(__ds_scope, { Chip });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Chip.jsx", error: String((e && e.message) || e) }); }

// components/core/IconButton.jsx
try { (() => {
const V = {
  ghost: {
    background: 'transparent',
    color: 'var(--text-body)'
  },
  raised: {
    background: 'var(--surface-raised)',
    color: 'var(--text-body)',
    border: '1px solid var(--border-hairline)'
  },
  glass: {
    background: 'rgba(255,255,255,.16)',
    color: '#fff',
    backdropFilter: 'blur(12px)',
    WebkitBackdropFilter: 'blur(12px)'
  },
  signal: {
    background: 'var(--signal)',
    color: '#fff'
  }
};
function IconButton({
  variant = 'ghost',
  size = 44,
  label,
  badge = false,
  children,
  onClick,
  style
}) {
  return /*#__PURE__*/React.createElement("button", {
    "aria-label": label,
    onClick: onClick,
    style: {
      position: 'relative',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: size,
      height: size,
      borderRadius: 'var(--r-pill)',
      border: 'none',
      cursor: 'pointer',
      transition: 'transform var(--dur-fast) var(--ease-out)',
      ...V[variant],
      ...style
    },
    onPointerDown: e => e.currentTarget.style.transform = 'scale(var(--press-scale))',
    onPointerUp: e => {
      e.currentTarget.style.transform = '';
    },
    onPointerLeave: e => {
      e.currentTarget.style.transform = '';
    }
  }, children, badge && /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'absolute',
      top: 6,
      right: 6,
      width: 8,
      height: 8,
      borderRadius: 99,
      background: 'var(--signal)'
    }
  }));
}
Object.assign(__ds_scope, { IconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/IconButton.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Sheet.jsx
try { (() => {
function Sheet({
  title,
  open = true,
  onClose,
  children,
  width = 390,
  style
}) {
  if (!open) return null;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      width,
      fontFamily: 'var(--font-body)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      background: 'var(--surface-raised)',
      borderRadius: 'var(--r-sheet) var(--r-sheet) 0 0',
      boxShadow: 'var(--shadow-sheet)',
      padding: '8px 20px 24px',
      boxSizing: 'border-box'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 36,
      height: 4,
      borderRadius: 99,
      background: 'var(--surface-pressed)',
      margin: '4px auto 14px'
    }
  }), title && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginBottom: 14
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-display)',
      fontWeight: 700,
      fontSize: 19,
      color: 'var(--text-body)'
    }
  }, title), onClose && /*#__PURE__*/React.createElement("button", {
    onClick: onClose,
    "aria-label": "Close",
    style: {
      border: 'none',
      background: 'var(--surface-pressed)',
      color: 'var(--text-muted)',
      width: 30,
      height: 30,
      borderRadius: 99,
      cursor: 'pointer',
      fontSize: 15,
      lineHeight: 1
    }
  }, "\xD7")), children));
}
Object.assign(__ds_scope, { Sheet });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Sheet.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Toast.jsx
try { (() => {
function Toast({
  icon,
  children,
  action,
  onAction,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 10,
      height: 48,
      padding: '0 18px',
      borderRadius: 'var(--r-pill)',
      background: 'var(--surface-pressed)',
      boxShadow: 'var(--shadow-nav)',
      border: '1px solid var(--border-hairline)',
      color: 'var(--text-body)',
      fontFamily: 'var(--font-body)',
      fontSize: 14,
      fontWeight: 500,
      ...style
    }
  }, icon && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      color: 'var(--track)'
    }
  }, icon), children, action && /*#__PURE__*/React.createElement("button", {
    onClick: onAction,
    style: {
      border: 'none',
      background: 'transparent',
      color: 'var(--signal)',
      fontWeight: 700,
      fontSize: 14,
      cursor: 'pointer',
      fontFamily: 'var(--font-body)',
      padding: '0 0 0 6px'
    }
  }, action));
}
Object.assign(__ds_scope, { Toast });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Toast.jsx", error: String((e && e.message) || e) }); }

// components/forms/Checkbox.jsx
try { (() => {
function Checkbox({
  checked = false,
  onChange,
  size = 26,
  style
}) {
  return /*#__PURE__*/React.createElement("span", {
    onClick: () => onChange && onChange(!checked),
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: size,
      height: size,
      borderRadius: 'var(--r-pill)',
      cursor: 'pointer',
      flexShrink: 0,
      boxSizing: 'border-box',
      background: checked ? 'var(--track)' : 'transparent',
      border: checked ? 'none' : '2px solid var(--border-hairline)',
      transition: 'background var(--dur-fast),transform var(--dur-med) var(--ease-spring)',
      ...style
    }
  }, checked && /*#__PURE__*/React.createElement("svg", {
    width: size * .55,
    height: size * .55,
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "#0C1014",
    strokeWidth: "3.4",
    strokeLinecap: "round",
    strokeLinejoin: "round"
  }, /*#__PURE__*/React.createElement("path", {
    d: "M20 6 9 17l-5-5"
  })));
}
Object.assign(__ds_scope, { Checkbox });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Checkbox.jsx", error: String((e && e.message) || e) }); }

// components/forms/Input.jsx
try { (() => {
function Input({
  label,
  placeholder,
  value,
  onChange,
  type = 'text',
  hint,
  error,
  style
}) {
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: 'block',
      fontFamily: 'var(--font-body)',
      ...style
    }
  }, label && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 13,
      fontWeight: 600,
      color: 'var(--text-muted)',
      marginBottom: 6
    }
  }, label), /*#__PURE__*/React.createElement("input", {
    type: type,
    placeholder: placeholder,
    value: value,
    onChange: e => onChange && onChange(e.target.value),
    style: {
      width: '100%',
      boxSizing: 'border-box',
      height: 48,
      padding: '0 16px',
      borderRadius: 'var(--r-control)',
      background: 'var(--surface-raised)',
      color: 'var(--text-body)',
      fontSize: 15,
      fontFamily: 'var(--font-body)',
      border: error ? '1px solid var(--alert)' : '1px solid var(--border-hairline)',
      outline: 'none'
    }
  }), (error || hint) && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 12,
      marginTop: 6,
      color: error ? 'var(--alert)' : 'var(--text-faint)'
    }
  }, error || hint));
}
Object.assign(__ds_scope, { Input });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Input.jsx", error: String((e && e.message) || e) }); }

// components/forms/SearchField.jsx
try { (() => {
function SearchField({
  placeholder = 'Search anything',
  value,
  onChange,
  icon,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      height: 48,
      padding: '0 18px',
      borderRadius: 'var(--r-pill)',
      background: 'var(--surface-raised)',
      border: '1px solid var(--border-hairline)',
      fontFamily: 'var(--font-body)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      color: 'var(--text-faint)'
    }
  }, icon || '⌕'), /*#__PURE__*/React.createElement("input", {
    placeholder: placeholder,
    value: value,
    onChange: e => onChange && onChange(e.target.value),
    style: {
      flex: 1,
      background: 'transparent',
      border: 'none',
      outline: 'none',
      color: 'var(--text-body)',
      fontSize: 15,
      fontFamily: 'var(--font-body)'
    }
  }));
}
Object.assign(__ds_scope, { SearchField });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/SearchField.jsx", error: String((e && e.message) || e) }); }

// components/forms/SegmentedControl.jsx
try { (() => {
function SegmentedControl({
  segments = [],
  value,
  onChange,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'inline-flex',
      gap: 2,
      padding: 3,
      borderRadius: 'var(--r-pill)',
      background: 'var(--surface-card)',
      border: '1px solid var(--border-hairline)',
      fontFamily: 'var(--font-body)',
      ...style
    }
  }, segments.map(s => {
    const active = s === value;
    return /*#__PURE__*/React.createElement("button", {
      key: s,
      onClick: () => onChange && onChange(s),
      style: {
        height: 36,
        padding: '0 16px',
        borderRadius: 'var(--r-pill)',
        border: 'none',
        cursor: 'pointer',
        fontSize: 14,
        fontWeight: 600,
        fontFamily: 'var(--font-body)',
        background: active ? 'var(--surface-pressed)' : 'transparent',
        color: active ? 'var(--text-body)' : 'var(--text-muted)',
        transition: 'background var(--dur-fast),color var(--dur-fast)'
      }
    }, s);
  }));
}
Object.assign(__ds_scope, { SegmentedControl });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/SegmentedControl.jsx", error: String((e && e.message) || e) }); }

// components/forms/Switch.jsx
try { (() => {
function Switch({
  checked = false,
  onChange,
  label,
  style
}) {
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 12,
      cursor: 'pointer',
      fontFamily: 'var(--font-body)',
      fontSize: 15,
      color: 'var(--text-body)',
      ...style
    }
  }, label, /*#__PURE__*/React.createElement("span", {
    onClick: () => onChange && onChange(!checked),
    style: {
      width: 50,
      height: 30,
      borderRadius: 99,
      padding: 3,
      boxSizing: 'border-box',
      flexShrink: 0,
      background: checked ? 'var(--signal)' : 'var(--surface-pressed)',
      transition: 'background var(--dur-fast)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      width: 24,
      height: 24,
      borderRadius: 99,
      background: '#fff',
      transform: checked ? 'translateX(20px)' : 'none',
      transition: 'transform var(--dur-med) var(--ease-spring)',
      boxShadow: '0 1px 3px rgba(0,0,0,.3)'
    }
  })));
}
Object.assign(__ds_scope, { Switch });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Switch.jsx", error: String((e && e.message) || e) }); }

// components/media/PosterPlaceholder.jsx
try { (() => {
const HUES = [[258, 36], [204, 42], [24, 48], [340, 38], [152, 30], [48, 44]];
function PosterPlaceholder({
  title = '',
  width = 110,
  ratio = 1.5,
  radius = 'var(--r-poster)',
  style
}) {
  const [h, s] = HUES[(title.length + (title.charCodeAt(0) || 0)) % HUES.length];
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width,
      height: Math.round(width * ratio),
      borderRadius: radius,
      overflow: 'hidden',
      flexShrink: 0,
      background: `linear-gradient(160deg,hsl(${h} ${s}% 26%),hsl(${(h + 40) % 360} ${s}% 14%))`,
      display: 'flex',
      alignItems: 'flex-end',
      padding: 10,
      boxSizing: 'border-box',
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-display)',
      fontWeight: 700,
      fontSize: Math.max(11, width * .11),
      lineHeight: 1.15,
      letterSpacing: '-.01em',
      color: 'rgba(255,255,255,.92)'
    }
  }, title));
}
Object.assign(__ds_scope, { PosterPlaceholder });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/media/PosterPlaceholder.jsx", error: String((e && e.message) || e) }); }

// components/media/ProgressBar.jsx
try { (() => {
function ProgressBar({
  value = 0,
  color = 'var(--track)',
  height = 4,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width: '100%',
      height,
      borderRadius: 99,
      background: 'var(--surface-pressed)',
      overflow: 'hidden',
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: `${Math.max(0, Math.min(100, value))}%`,
      height: '100%',
      borderRadius: 99,
      background: color,
      transition: 'width var(--dur-slow) var(--ease-out)'
    }
  }));
}
Object.assign(__ds_scope, { ProgressBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/media/ProgressBar.jsx", error: String((e && e.message) || e) }); }

// components/media/PosterCard.jsx
try { (() => {
function PosterCard({
  title,
  year,
  width = 110,
  src,
  progress,
  badge,
  onClick,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    onClick: onClick,
    style: {
      width,
      cursor: onClick ? 'pointer' : 'default',
      fontFamily: 'var(--font-body)',
      flexShrink: 0,
      position: 'relative',
      ...style
    }
  }, badge && /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'absolute',
      top: 8,
      left: 8,
      zIndex: 1
    }
  }, badge), src ? /*#__PURE__*/React.createElement("img", {
    src: src,
    alt: title,
    style: {
      width,
      height: Math.round(width * 1.5),
      objectFit: 'cover',
      borderRadius: 'var(--r-poster)',
      display: 'block'
    }
  }) : /*#__PURE__*/React.createElement(__ds_scope.PosterPlaceholder, {
    title: title,
    width: width
  }), typeof progress === 'number' && /*#__PURE__*/React.createElement(__ds_scope.ProgressBar, {
    value: progress,
    style: {
      marginTop: 6
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 6,
      fontSize: 13,
      fontWeight: 600,
      color: 'var(--text-body)',
      lineHeight: 1.3,
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      display: '-webkit-box',
      WebkitLineClamp: 2,
      WebkitBoxOrient: 'vertical'
    }
  }, title, year && /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--text-faint)',
      fontWeight: 400
    }
  }, " ", year)));
}
Object.assign(__ds_scope, { PosterCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/media/PosterCard.jsx", error: String((e && e.message) || e) }); }

// components/media/ProgressRing.jsx
try { (() => {
function ProgressRing({
  value = 0,
  size = 56,
  stroke = 5,
  color = 'var(--track)',
  label,
  children,
  style
}) {
  const r = (size - stroke) / 2,
    c = 2 * Math.PI * r,
    pct = Math.max(0, Math.min(100, value));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      width: size,
      height: size,
      flexShrink: 0,
      ...style
    }
  }, /*#__PURE__*/React.createElement("svg", {
    width: size,
    height: size,
    style: {
      transform: 'rotate(-90deg)'
    }
  }, /*#__PURE__*/React.createElement("circle", {
    cx: size / 2,
    cy: size / 2,
    r: r,
    fill: "none",
    stroke: "var(--surface-pressed)",
    strokeWidth: stroke
  }), /*#__PURE__*/React.createElement("circle", {
    cx: size / 2,
    cy: size / 2,
    r: r,
    fill: "none",
    stroke: color,
    strokeWidth: stroke,
    strokeLinecap: "round",
    strokeDasharray: c,
    strokeDashoffset: c * (1 - pct / 100),
    style: {
      transition: 'stroke-dashoffset var(--dur-slow) var(--ease-out)'
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontFamily: 'var(--font-display)',
      fontWeight: 700,
      fontSize: size * .26,
      color: 'var(--text-body)'
    }
  }, children ?? label ?? `${Math.round(pct)}%`));
}
Object.assign(__ds_scope, { ProgressRing });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/media/ProgressRing.jsx", error: String((e && e.message) || e) }); }

// components/media/RatingHistogram.jsx
try { (() => {
function RatingHistogram({
  bins = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  average,
  height = 64,
  style
}) {
  const max = Math.max(...bins, 1);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      gap: 12,
      fontFamily: 'var(--font-body)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      gap: 2,
      flex: 1,
      height
    }
  }, bins.map((b, i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    style: {
      flex: 1,
      borderRadius: '3px 3px 0 0',
      background: 'var(--surface-pressed)',
      height: `${Math.max(3, b / max * 100)}%`,
      transition: 'height var(--dur-slow) var(--ease-out)'
    }
  }))), average != null && /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'right'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontWeight: 700,
      fontSize: 26,
      color: 'var(--text-muted)',
      lineHeight: 1
    }
  }, average), /*#__PURE__*/React.createElement("div", {
    style: {
      color: 'var(--star)',
      fontSize: 12,
      letterSpacing: 1
    }
  }, "\u2605\u2605\u2605\u2605\u2605")));
}
Object.assign(__ds_scope, { RatingHistogram });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/media/RatingHistogram.jsx", error: String((e && e.message) || e) }); }

// components/media/RatingStars.jsx
try { (() => {
function Star({
  fill
}) {
  // fill: 0, .5, 1
  const id = React.useId();
  return /*#__PURE__*/React.createElement("svg", {
    width: "16",
    height: "16",
    viewBox: "0 0 24 24",
    style: {
      display: 'block'
    }
  }, /*#__PURE__*/React.createElement("defs", null, /*#__PURE__*/React.createElement("linearGradient", {
    id: id
  }, /*#__PURE__*/React.createElement("stop", {
    offset: "50%",
    stopColor: "var(--star)"
  }), /*#__PURE__*/React.createElement("stop", {
    offset: "50%",
    stopColor: "var(--surface-pressed)"
  }))), /*#__PURE__*/React.createElement("path", {
    d: "M12 2.6l2.9 6 6.6.9-4.8 4.6 1.2 6.5L12 17.5l-5.9 3.1 1.2-6.5L2.5 9.5l6.6-.9z",
    fill: fill === 1 ? 'var(--star)' : fill === .5 ? `url(#${id})` : 'var(--surface-pressed)'
  }));
}
function RatingStars({
  value = 0,
  size = 16,
  interactive = false,
  onChange,
  style
}) {
  const [hover, setHover] = React.useState(null);
  const v = hover ?? value;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'inline-flex',
      gap: 2,
      ...style
    },
    onMouseLeave: () => setHover(null)
  }, [1, 2, 3, 4, 5].map(i => /*#__PURE__*/React.createElement("span", {
    key: i,
    style: {
      cursor: interactive ? 'pointer' : 'default',
      transform: `scale(${size / 16})`,
      transformOrigin: 'left center',
      width: size,
      height: size,
      display: 'inline-flex'
    },
    onMouseEnter: interactive ? () => setHover(i) : undefined,
    onClick: interactive ? () => onChange && onChange(i === value ? i - 0.5 : i) : undefined
  }, /*#__PURE__*/React.createElement(Star, {
    fill: v >= i ? 1 : v >= i - 0.5 ? 0.5 : 0
  }))));
}
Object.assign(__ds_scope, { RatingStars });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/media/RatingStars.jsx", error: String((e && e.message) || e) }); }

// components/media/EpisodeRow.jsx
try { (() => {
function EpisodeRow({
  day,
  title,
  year,
  code,
  meta,
  rating,
  rewatch = false,
  trailing,
  src,
  onClick,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    onClick: onClick,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '10px 0',
      borderBottom: '1px solid var(--border-hairline)',
      fontFamily: 'var(--font-body)',
      cursor: onClick ? 'pointer' : 'default',
      ...style
    }
  }, day != null && /*#__PURE__*/React.createElement("div", {
    style: {
      width: 44,
      height: 52,
      borderRadius: 8,
      border: '1px solid var(--border-hairline)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      flexShrink: 0,
      fontFamily: 'var(--font-display)',
      fontWeight: 600,
      fontSize: 17,
      color: 'var(--text-muted)'
    }
  }, day), src ? /*#__PURE__*/React.createElement("img", {
    src: src,
    alt: "",
    style: {
      width: 38,
      height: 56,
      objectFit: 'cover',
      borderRadius: 6,
      flexShrink: 0
    }
  }) : /*#__PURE__*/React.createElement(__ds_scope.PosterPlaceholder, {
    title: title,
    width: 38,
    radius: "6px"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 16,
      fontWeight: 600,
      color: 'var(--text-body)',
      lineHeight: 1.3
    }
  }, title, " ", year && /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--text-faint)',
      fontWeight: 400,
      fontSize: 14
    }
  }, year)), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      marginTop: 3
    }
  }, code && /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-code)',
      fontSize: 12,
      color: 'var(--text-faint)'
    }
  }, code), rating != null && /*#__PURE__*/React.createElement(__ds_scope.RatingStars, {
    value: rating,
    size: 13
  }), rewatch && /*#__PURE__*/React.createElement("svg", {
    width: "13",
    height: "13",
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "var(--text-faint)",
    strokeWidth: "2.5",
    strokeLinecap: "round",
    strokeLinejoin: "round"
  }, /*#__PURE__*/React.createElement("path", {
    d: "M3 12a9 9 0 0 1 15.6-6.2L21 8M21 3v5h-5M21 12a9 9 0 0 1-15.6 6.2L3 16M3 21v-5h5"
  })), meta && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      color: 'var(--text-faint)'
    }
  }, meta))), trailing);
}
Object.assign(__ds_scope, { EpisodeRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/media/EpisodeRow.jsx", error: String((e && e.message) || e) }); }

// components/navigation/BottomNav.jsx
try { (() => {
function BottomNav({
  items = [],
  activeIndex = 0,
  onChange,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 4,
      padding: 8,
      borderRadius: 'var(--r-pill)',
      background: 'var(--nav-glass)',
      backdropFilter: 'var(--blur-glass)',
      WebkitBackdropFilter: 'var(--blur-glass)',
      boxShadow: 'var(--shadow-nav)',
      border: '1px solid var(--border-hairline)',
      width: 'fit-content',
      ...style
    }
  }, items.map((it, i) => {
    const active = i === activeIndex;
    return /*#__PURE__*/React.createElement("button", {
      key: i,
      "aria-label": it.label,
      onClick: () => onChange && onChange(i),
      style: {
        position: 'relative',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        width: 52,
        height: 48,
        borderRadius: 'var(--r-pill)',
        border: 'none',
        cursor: 'pointer',
        background: active ? 'var(--surface-pressed)' : 'transparent',
        color: it.accent ? 'var(--signal)' : active ? 'var(--text-body)' : 'var(--text-faint)',
        transition: 'background var(--dur-fast),color var(--dur-fast)'
      }
    }, it.icon, it.dot && /*#__PURE__*/React.createElement("span", {
      style: {
        position: 'absolute',
        top: 9,
        right: 13,
        width: 7,
        height: 7,
        borderRadius: 99,
        background: 'var(--signal)'
      }
    }));
  }));
}
Object.assign(__ds_scope, { BottomNav });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/BottomNav.jsx", error: String((e && e.message) || e) }); }

// components/navigation/TopBar.jsx
try { (() => {
function TopBar({
  title,
  overline,
  leading,
  actions,
  transparent = false,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      height: 56,
      padding: '0 12px',
      fontFamily: 'var(--font-body)',
      boxSizing: 'border-box',
      background: transparent ? 'transparent' : 'var(--nav-glass)',
      backdropFilter: transparent ? undefined : 'var(--blur-glass)',
      WebkitBackdropFilter: transparent ? undefined : 'var(--blur-glass)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 44,
      display: 'flex',
      justifyContent: 'flex-start'
    }
  }, leading), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      textAlign: 'center',
      minWidth: 0
    }
  }, overline && /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 11,
      letterSpacing: 'var(--track-overline)',
      textTransform: 'uppercase',
      color: 'var(--text-faint)',
      fontWeight: 600
    }
  }, overline), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontWeight: 700,
      fontSize: 17,
      color: 'var(--text-body)',
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      textOverflow: 'ellipsis'
    }
  }, title)), /*#__PURE__*/React.createElement("div", {
    style: {
      minWidth: 44,
      display: 'flex',
      justifyContent: 'flex-end',
      gap: 4
    }
  }, actions));
}
Object.assign(__ds_scope, { TopBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/TopBar.jsx", error: String((e && e.message) || e) }); }

// ui_kits/myserial-app/DiaryScreen.jsx
try { (() => {
const DS4 = window.MySerialDesignSystem_514ab4;
const LD = ({
  n,
  s = 20,
  style
}) => /*#__PURE__*/React.createElement("span", {
  style: {
    width: s,
    height: s,
    display: 'inline-flex',
    ...style
  },
  dangerouslySetInnerHTML: {
    __html: lucideSvg(n, s)
  }
});
function DiaryScreen({
  openShow
}) {
  const D = window.MS_DATA;
  const {
    TopBar,
    IconButton,
    EpisodeRow
  } = DS4;
  return /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement(TopBar, {
    overline: D.user.name.split(' ')[0],
    title: "Diary",
    leading: /*#__PURE__*/React.createElement(IconButton, {
      label: "Back"
    }, /*#__PURE__*/React.createElement(LD, {
      n: "chevron-left"
    })),
    actions: /*#__PURE__*/React.createElement(IconButton, {
      label: "Filter"
    }, /*#__PURE__*/React.createElement(LD, {
      n: "sliders-horizontal",
      s: 18
    }))
  }), D.diary.map(m => /*#__PURE__*/React.createElement("div", {
    key: m.month
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '10px 20px',
      background: 'var(--surface-card)',
      fontSize: 12,
      letterSpacing: 'var(--track-overline)',
      textTransform: 'uppercase',
      fontWeight: 600,
      color: 'var(--text-faint)'
    }
  }, m.month), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '0 20px'
    }
  }, m.rows.map((r, i) => /*#__PURE__*/React.createElement(EpisodeRow, {
    key: i,
    day: r.day,
    title: r.title,
    year: r.year,
    code: r.code,
    rating: r.rating,
    rewatch: r.rewatch,
    onClick: () => openShow(r.title)
  }))))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '16px 20px 120px',
      color: 'var(--text-faint)',
      fontSize: 13,
      textAlign: 'center'
    }
  }, "That's everything from September."));
}
window.DiaryScreen = DiaryScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/myserial-app/DiaryScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/myserial-app/HomeScreen.jsx
try { (() => {
const DS = window.MySerialDesignSystem_514ab4;
const L = ({
  n,
  s = 20,
  style
}) => /*#__PURE__*/React.createElement("span", {
  style: {
    width: s,
    height: s,
    display: 'inline-flex',
    ...style
  },
  dangerouslySetInnerHTML: {
    __html: lucideSvg(n, s)
  }
});
const Section = ({
  title,
  action,
  children
}) => /*#__PURE__*/React.createElement("div", {
  style: {
    marginTop: 24
  }
}, /*#__PURE__*/React.createElement("div", {
  style: {
    display: 'flex',
    alignItems: 'baseline',
    justifyContent: 'space-between',
    padding: '0 20px',
    marginBottom: 12
  }
}, /*#__PURE__*/React.createElement("span", {
  style: {
    fontFamily: 'var(--font-display)',
    fontWeight: 700,
    fontSize: 'var(--type-title)',
    letterSpacing: 'var(--track-display)',
    color: 'var(--text-body)'
  }
}, title), action && /*#__PURE__*/React.createElement("span", {
  style: {
    fontSize: 13,
    fontWeight: 600,
    color: 'var(--text-link)'
  }
}, action)), children);
const Rail = ({
  children
}) => /*#__PURE__*/React.createElement("div", {
  style: {
    display: 'flex',
    gap: 'var(--rail-gap)',
    overflowX: 'auto',
    padding: '0 20px',
    scrollbarWidth: 'none'
  }
}, children);
function HomeScreen({
  openShow
}) {
  const D = window.MS_DATA;
  const {
    IconButton,
    Button,
    PosterCard,
    Badge,
    ProgressBar,
    PosterPlaceholder
  } = DS;
  return /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '14px 20px 0'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-display)',
      fontWeight: 800,
      fontSize: 24,
      letterSpacing: '-.03em',
      color: 'var(--fg-1)'
    }
  }, "MySerial", /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--signal)'
    }
  }, ".")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 4
    }
  }, /*#__PURE__*/React.createElement(IconButton, {
    label: "Notifications",
    badge: true
  }, /*#__PURE__*/React.createElement(L, {
    n: "bell",
    s: 20
  })))), /*#__PURE__*/React.createElement(Section, {
    title: "Tonight"
  }, /*#__PURE__*/React.createElement("div", {
    onClick: () => openShow(),
    style: {
      margin: '0 20px',
      position: 'relative',
      borderRadius: 'var(--r-card)',
      overflow: 'hidden',
      cursor: 'pointer'
    }
  }, /*#__PURE__*/React.createElement(PosterPlaceholder, {
    title: "",
    width: 350,
    ratio: .62,
    radius: "0",
    style: {
      width: '100%'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      background: 'var(--scrim-poster)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: 16,
      right: 16,
      bottom: 14
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 11,
      letterSpacing: 'var(--track-overline)',
      textTransform: 'uppercase',
      color: 'var(--fg-2)',
      fontWeight: 600,
      marginBottom: 4
    }
  }, "Continue watching"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontWeight: 700,
      fontSize: 24,
      letterSpacing: '-.02em',
      color: '#fff'
    }
  }, D.tonight.title), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      margin: '4px 0 10px'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-code)',
      fontSize: 12,
      color: 'var(--fg-2)'
    }
  }, D.tonight.code), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      color: 'var(--fg-2)'
    }
  }, D.tonight.ep, " \xB7 ", D.tonight.left)), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(Button, {
    size: "sm",
    icon: /*#__PURE__*/React.createElement(L, {
      n: "play",
      s: 15
    })
  }, "Resume"), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement(ProgressBar, {
    value: D.tonight.progress
  })))))), /*#__PURE__*/React.createElement(Section, {
    title: "Up next for you"
  }, /*#__PURE__*/React.createElement(Rail, null, D.upNext.map(s => /*#__PURE__*/React.createElement(PosterCard, {
    key: s.title,
    title: s.title,
    year: s.year,
    progress: s.progress,
    onClick: () => openShow(s.title)
  })))), /*#__PURE__*/React.createElement(Section, {
    title: "New this week",
    action: "See all"
  }, /*#__PURE__*/React.createElement(Rail, null, D.newWeek.map(s => /*#__PURE__*/React.createElement(PosterCard, {
    key: s.title,
    title: s.title,
    year: s.year,
    onClick: () => openShow(s.title),
    badge: /*#__PURE__*/React.createElement(Badge, {
      variant: s.badge === 'Finale' ? 'neutral' : 'signal'
    }, s.badge)
  })))));
}
window.HomeScreen = HomeScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/myserial-app/HomeScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/myserial-app/ProfileScreen.jsx
try { (() => {
const DS5 = window.MySerialDesignSystem_514ab4;
const LP = ({
  n,
  s = 20,
  style
}) => /*#__PURE__*/React.createElement("span", {
  style: {
    width: s,
    height: s,
    display: 'inline-flex',
    ...style
  },
  dangerouslySetInnerHTML: {
    __html: lucideSvg(n, s)
  }
});
function ProfileScreen() {
  const D = window.MS_DATA,
    U = D.user;
  const {
    Avatar,
    SegmentedControl,
    ProgressRing,
    Switch,
    PosterCard,
    Chip
  } = DS5;
  const [tab, setTab] = React.useState('Stats');
  const [notif, setNotif] = React.useState(true);
  const [spoiler, setSpoiler] = React.useState(false);
  const Stat = ({
    v,
    l
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontWeight: 800,
      fontSize: 26,
      letterSpacing: '-.02em',
      color: 'var(--text-body)'
    }
  }, v), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-faint)'
    }
  }, l));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '20px 20px 0'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 14
    }
  }, /*#__PURE__*/React.createElement(Avatar, {
    name: U.name,
    size: 64,
    ring: true
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontWeight: 700,
      fontSize: 22,
      color: 'var(--text-body)'
    }
  }, U.name), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: 'var(--text-faint)'
    }
  }, U.handle))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      margin: '16px 0',
      background: 'var(--surface-card)',
      borderRadius: 'var(--r-card)',
      padding: '14px 8px',
      border: '1px solid var(--border-hairline)'
    }
  }, /*#__PURE__*/React.createElement(Stat, {
    v: U.shows,
    l: "shows"
  }), /*#__PURE__*/React.createElement(Stat, {
    v: U.episodes,
    l: "episodes"
  }), /*#__PURE__*/React.createElement(Stat, {
    v: `${U.streak}d`,
    l: "streak"
  })), /*#__PURE__*/React.createElement(SegmentedControl, {
    segments: ['Stats', 'Lists', 'Likes'],
    value: tab,
    onChange: setTab,
    style: {
      width: '100%',
      display: 'flex'
    }
  }), tab === 'Stats' && /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 16,
      margin: '18px 0',
      background: 'var(--surface-card)',
      borderRadius: 'var(--r-card)',
      padding: 16,
      border: '1px solid var(--border-hairline)'
    }
  }, /*#__PURE__*/React.createElement(ProgressRing, {
    value: U.goal.done / U.goal.target * 100,
    size: 64,
    label: `${U.goal.done}`
  }), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 15,
      fontWeight: 600,
      color: 'var(--text-body)'
    }
  }, "2025 goal"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: 'var(--text-muted)'
    }
  }, U.goal.done, " of ", U.goal.target, " shows finished \u2014 nice pace."))), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      letterSpacing: 'var(--track-overline)',
      textTransform: 'uppercase',
      fontWeight: 600,
      color: 'var(--text-faint)',
      marginBottom: 10
    }
  }, "Settings"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 14,
      paddingBottom: 120
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 15,
      color: 'var(--text-body)'
    }
  }, "Episode notifications"), /*#__PURE__*/React.createElement(Switch, {
    checked: notif,
    onChange: setNotif
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 15,
      color: 'var(--text-body)'
    }
  }, "Hide spoilers in reviews"), /*#__PURE__*/React.createElement(Switch, {
    checked: spoiler,
    onChange: setSpoiler
  })))), tab === 'Lists' && /*#__PURE__*/React.createElement("div", {
    style: {
      margin: '18px 0 120px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexWrap: 'wrap',
      gap: 8
    }
  }, ['Slow-burn sci-fi', 'Comfort rewatches', 'Finales that stuck the landing'].map(l => /*#__PURE__*/React.createElement(Chip, {
    key: l
  }, l)))), tab === 'Likes' && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: 'repeat(3,1fr)',
      gap: 12,
      margin: '18px 0 120px'
    }
  }, window.MS_DATA.popular.slice(0, 3).map(s => /*#__PURE__*/React.createElement(PosterCard, {
    key: s.title,
    title: s.title,
    year: s.year,
    style: {
      width: '100%'
    }
  }))));
}
window.ProfileScreen = ProfileScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/myserial-app/ProfileScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/myserial-app/SearchScreen.jsx
try { (() => {
const DS2 = window.MySerialDesignSystem_514ab4;
const LI = ({
  n,
  s = 20,
  style
}) => /*#__PURE__*/React.createElement("span", {
  style: {
    width: s,
    height: s,
    display: 'inline-flex',
    ...style
  },
  dangerouslySetInnerHTML: {
    __html: lucideSvg(n, s)
  }
});
function SearchScreen({
  openShow
}) {
  const D = window.MS_DATA;
  const {
    SearchField,
    Chip,
    PosterCard
  } = DS2;
  const [q, setQ] = React.useState('');
  const results = D.popular.filter(s => s.title.toLowerCase().includes(q.toLowerCase()));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '14px 20px 0'
    }
  }, /*#__PURE__*/React.createElement(SearchField, {
    value: q,
    onChange: setQ,
    icon: /*#__PURE__*/React.createElement(LI, {
      n: "search"
    })
  }), !q && /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontWeight: 700,
      fontSize: 'var(--type-title)',
      color: 'var(--text-body)',
      margin: '22px 0 12px'
    }
  }, "Recent"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexWrap: 'wrap',
      gap: 8
    }
  }, D.recent.map(r => /*#__PURE__*/React.createElement(Chip, {
    key: r,
    icon: r.startsWith('#') ? undefined : r[0] === r[0].toUpperCase() ? /*#__PURE__*/React.createElement(LI, {
      n: "map-pin",
      s: 14
    }) : /*#__PURE__*/React.createElement(LI, {
      n: "circle-user-round",
      s: 14
    })
  }, r)))), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontWeight: 700,
      fontSize: 'var(--type-title)',
      color: 'var(--text-body)',
      margin: '22px 0 12px'
    }
  }, q ? `Results for “${q}”` : 'Popular this week'), results.length === 0 && /*#__PURE__*/React.createElement("div", {
    style: {
      color: 'var(--text-muted)',
      fontSize: 15
    }
  }, "Nothing found. Try another title \u2192"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: 'repeat(3,1fr)',
      gap: 12
    }
  }, results.map(s => /*#__PURE__*/React.createElement(PosterCard, {
    key: s.title,
    title: s.title,
    year: s.year,
    width: 106,
    onClick: () => openShow(s.title),
    style: {
      width: '100%'
    }
  }))));
}
window.SearchScreen = SearchScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/myserial-app/SearchScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/myserial-app/ShowScreen.jsx
try { (() => {
const DS3 = window.MySerialDesignSystem_514ab4;
const LS = ({
  n,
  s = 20,
  style
}) => /*#__PURE__*/React.createElement("span", {
  style: {
    width: s,
    height: s,
    display: 'inline-flex',
    ...style
  },
  dangerouslySetInnerHTML: {
    __html: lucideSvg(n, s)
  }
});
function ShowScreen({
  title,
  goBack,
  onLog
}) {
  const D = window.MS_DATA,
    S = D.show;
  const {
    IconButton,
    Button,
    Badge,
    SegmentedControl,
    Checkbox,
    ProgressBar,
    RatingHistogram,
    PosterPlaceholder,
    Sheet,
    RatingStars,
    Toast
  } = DS3;
  const name = title || S.title;
  const [season, setSeason] = React.useState('Season 2');
  const [eps, setEps] = React.useState(S.episodes);
  const [sheet, setSheet] = React.useState(false);
  const [stars, setStars] = React.useState(4);
  const [toast, setToast] = React.useState(null);
  const watched = eps.filter(e => e.watched).length;
  const toggle = i => {
    const next = eps.map((e, j) => j === i ? {
      ...e,
      watched: !e.watched
    } : e);
    setEps(next);
    if (!eps[i].watched) {
      setToast(`Marked ${eps[i].code} watched`);
      setTimeout(() => setToast(null), 2200);
    }
  };
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      minHeight: '100%'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative'
    }
  }, /*#__PURE__*/React.createElement(PosterPlaceholder, {
    title: "",
    width: 390,
    ratio: .72,
    radius: "0",
    style: {
      width: '100%'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      background: 'var(--scrim-poster)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      top: 10,
      left: 12,
      right: 12,
      display: 'flex',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement(IconButton, {
    variant: "glass",
    label: "Back",
    onClick: goBack
  }, /*#__PURE__*/React.createElement(LS, {
    n: "chevron-left"
  })), /*#__PURE__*/React.createElement(IconButton, {
    variant: "glass",
    label: "More"
  }, /*#__PURE__*/React.createElement(LS, {
    n: "ellipsis"
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: 20,
      right: 20,
      bottom: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      marginBottom: 8
    }
  }, /*#__PURE__*/React.createElement(Badge, {
    variant: "signal"
  }, "Returning"), /*#__PURE__*/React.createElement(Badge, {
    variant: "outline",
    style: {
      color: '#fff'
    }
  }, "Sci-fi")), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontWeight: 800,
      fontSize: 30,
      letterSpacing: '-.02em',
      color: '#fff',
      lineHeight: 1.1
    }
  }, name), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: 'var(--fg-2)',
      marginTop: 6
    }
  }, S.year, " \xB7 Created by ", /*#__PURE__*/React.createElement("b", {
    style: {
      color: 'var(--fg-1)',
      fontWeight: 600
    }
  }, S.creator), " \xB7 ", S.seasons, " seasons"))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '16px 20px 0'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 10
    }
  }, /*#__PURE__*/React.createElement(Button, {
    icon: /*#__PURE__*/React.createElement(LS, {
      n: "plus",
      s: 17
    }),
    onClick: () => setSheet(true),
    style: {
      flex: 1
    }
  }, "Log"), /*#__PURE__*/React.createElement(Button, {
    variant: "secondary",
    icon: /*#__PURE__*/React.createElement(LS, {
      n: "bookmark",
      s: 17
    }),
    style: {
      flex: 1
    }
  }, "Watchlist")), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      letterSpacing: 'var(--track-overline)',
      textTransform: 'uppercase',
      color: 'var(--text-faint)',
      fontWeight: 600,
      margin: '20px 0 6px'
    }
  }, S.tagline), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 15,
      lineHeight: 'var(--lh-body)',
      color: 'var(--text-muted)'
    }
  }, S.synopsis), /*#__PURE__*/React.createElement("div", {
    style: {
      margin: '18px 0'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      letterSpacing: 'var(--track-overline)',
      textTransform: 'uppercase',
      color: 'var(--text-faint)',
      fontWeight: 600,
      marginBottom: 8
    }
  }, "Ratings"), /*#__PURE__*/React.createElement(RatingHistogram, {
    bins: S.bins,
    average: S.rating,
    height: 52
  })), /*#__PURE__*/React.createElement(SegmentedControl, {
    segments: ['Season 1', 'Season 2'],
    value: season,
    onChange: setSeason
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      margin: '14px 0 4px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement(ProgressBar, {
    value: watched / eps.length * 100
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-code)',
      fontSize: 12,
      color: 'var(--text-faint)'
    }
  }, watched, "/", eps.length)), /*#__PURE__*/React.createElement("div", {
    style: {
      paddingBottom: 120
    }
  }, eps.map((e, i) => /*#__PURE__*/React.createElement("div", {
    key: e.code,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '12px 0',
      borderBottom: i < eps.length - 1 ? '1px solid var(--border-hairline)' : 'none'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-code)',
      fontSize: 12,
      color: 'var(--text-faint)',
      width: 56
    }
  }, e.code), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 15,
      fontWeight: 600,
      color: e.watched ? 'var(--text-faint)' : 'var(--text-body)'
    }
  }, e.name), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-faint)'
    }
  }, e.min, " min")), /*#__PURE__*/React.createElement(Checkbox, {
    checked: e.watched,
    onChange: () => toggle(i)
  }))))), sheet && /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'fixed',
      inset: 0,
      background: 'rgba(0,0,0,.5)',
      display: 'flex',
      alignItems: 'flex-end',
      justifyContent: 'center',
      zIndex: 5
    },
    onClick: () => setSheet(false)
  }, /*#__PURE__*/React.createElement("div", {
    onClick: e => e.stopPropagation(),
    style: {
      width: '100%',
      maxWidth: 390
    }
  }, /*#__PURE__*/React.createElement(Sheet, {
    title: "Log episode",
    onClose: () => setSheet(false),
    width: "100%"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      color: 'var(--text-muted)',
      fontSize: 13,
      marginBottom: 10
    }
  }, name, " \xB7 ", /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-code)',
      fontSize: 12
    }
  }, "S02E04"), " The Quiet Band"), /*#__PURE__*/React.createElement(RatingStars, {
    interactive: true,
    value: stars,
    onChange: setStars,
    size: 30
  }), /*#__PURE__*/React.createElement(Button, {
    fullWidth: true,
    style: {
      marginTop: 18
    },
    onClick: () => {
      setSheet(false);
      setToast('Logged to your diary');
      setTimeout(() => setToast(null), 2200);
    }
  }, "Save to diary")))), toast && /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'fixed',
      bottom: 110,
      left: 0,
      right: 0,
      display: 'flex',
      justifyContent: 'center',
      zIndex: 6
    }
  }, /*#__PURE__*/React.createElement(Toast, {
    icon: /*#__PURE__*/React.createElement(LS, {
      n: "check",
      s: 17
    })
  }, toast)));
}
window.ShowScreen = ShowScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/myserial-app/ShowScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/myserial-app/data.js
try { (() => {
window.MS_DATA = {
  user: {
    name: 'James Porter',
    handle: '@jamesp',
    shows: 64,
    episodes: 812,
    streak: 23,
    goal: {
      done: 47,
      target: 80
    }
  },
  tonight: {
    title: 'Signal Decay',
    code: 'S02E04',
    ep: 'The Quiet Band',
    left: '3 episodes left',
    progress: 62
  },
  upNext: [{
    title: 'Signal Decay',
    year: 2025,
    progress: 62,
    code: 'S02E04'
  }, {
    title: 'The Long Bright Dark',
    year: 2024,
    progress: 31,
    code: 'S01E03'
  }, {
    title: 'Palace of Glass',
    year: 2023,
    progress: 88,
    code: 'S03E09'
  }, {
    title: 'Low Orbit',
    year: 2025,
    progress: 12,
    code: 'S01E02'
  }],
  newWeek: [{
    title: 'Wren & Marlow',
    year: 2026,
    badge: 'New'
  }, {
    title: 'Night Grammar',
    year: 2026,
    badge: 'New'
  }, {
    title: 'Cold Harbor',
    year: 2025,
    badge: 'Finale'
  }, {
    title: 'The Understudy',
    year: 2026,
    badge: 'New'
  }],
  popular: [{
    title: 'Signal Decay',
    year: 2025
  }, {
    title: 'Wren & Marlow',
    year: 2026
  }, {
    title: 'Cold Harbor',
    year: 2025
  }, {
    title: 'Night Grammar',
    year: 2026
  }, {
    title: 'Palace of Glass',
    year: 2023
  }, {
    title: 'Low Orbit',
    year: 2025
  }, {
    title: 'The Understudy',
    year: 2026
  }, {
    title: 'The Long Bright Dark',
    year: 2024
  }, {
    title: 'Hotel Meridian',
    year: 2024
  }],
  show: {
    title: 'Signal Decay',
    year: 2025,
    creator: 'Mara Ellison',
    seasons: 2,
    rating: 4.4,
    tagline: 'SOME FREQUENCIES SHOULD STAY LOST.',
    synopsis: 'A pirate-radio engineer starts receiving broadcasts from a station that burned down in 1977 — and someone on the other end knows her name.',
    bins: [1, 0, 2, 3, 5, 8, 14, 30, 42, 28],
    episodes: [{
      code: 'S02E01',
      name: 'Dead Air',
      min: 48,
      watched: true
    }, {
      code: 'S02E02',
      name: 'Carrier Wave',
      min: 51,
      watched: true
    }, {
      code: 'S02E03',
      name: 'Numbers Station',
      min: 49,
      watched: true
    }, {
      code: 'S02E04',
      name: 'The Quiet Band',
      min: 52,
      watched: false
    }, {
      code: 'S02E05',
      name: 'Skywave',
      min: 54,
      watched: false
    }]
  },
  diary: [{
    month: 'October 2025',
    rows: [{
      day: 11,
      title: 'Signal Decay',
      year: 2025,
      code: 'S02E03',
      rating: 4.5
    }, {
      day: 10,
      title: 'Palace of Glass',
      year: 2023,
      code: 'S03E08',
      rating: 3.5
    }, {
      day: 10,
      title: 'The Long Bright Dark',
      year: 2024,
      code: 'S01E03',
      rating: 4.5,
      rewatch: true
    }, {
      day: 9,
      title: 'Low Orbit',
      year: 2025,
      code: 'S01E02',
      rating: 3
    }, {
      day: 4,
      title: 'Cold Harbor',
      year: 2025,
      code: 'S02E10',
      rating: 5
    }]
  }, {
    month: 'September 2025',
    rows: [{
      day: 27,
      title: 'Night Grammar',
      year: 2026,
      code: 'S01E01',
      rating: 3
    }, {
      day: 25,
      title: 'Signal Decay',
      year: 2025,
      code: 'S02E02',
      rating: 4
    }, {
      day: 24,
      title: 'Hotel Meridian',
      year: 2024,
      code: 'S01E06',
      rating: 3.5,
      rewatch: true
    }]
  }],
  recent: ['#slowburn', '#scifi', '#finale', 'Budapest', 'wren_watches', 'echo.mira']
};
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/myserial-app/data.js", error: String((e && e.message) || e) }); }

__ds_ns.Avatar = __ds_scope.Avatar;

__ds_ns.Badge = __ds_scope.Badge;

__ds_ns.Button = __ds_scope.Button;

__ds_ns.Chip = __ds_scope.Chip;

__ds_ns.IconButton = __ds_scope.IconButton;

__ds_ns.Sheet = __ds_scope.Sheet;

__ds_ns.Toast = __ds_scope.Toast;

__ds_ns.Checkbox = __ds_scope.Checkbox;

__ds_ns.Input = __ds_scope.Input;

__ds_ns.SearchField = __ds_scope.SearchField;

__ds_ns.SegmentedControl = __ds_scope.SegmentedControl;

__ds_ns.Switch = __ds_scope.Switch;

__ds_ns.EpisodeRow = __ds_scope.EpisodeRow;

__ds_ns.PosterCard = __ds_scope.PosterCard;

__ds_ns.PosterPlaceholder = __ds_scope.PosterPlaceholder;

__ds_ns.ProgressBar = __ds_scope.ProgressBar;

__ds_ns.ProgressRing = __ds_scope.ProgressRing;

__ds_ns.RatingHistogram = __ds_scope.RatingHistogram;

__ds_ns.RatingStars = __ds_scope.RatingStars;

__ds_ns.BottomNav = __ds_scope.BottomNav;

__ds_ns.TopBar = __ds_scope.TopBar;

})();
