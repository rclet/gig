# Rclet Guardian Mascot - Visual Design Documentation

## Mascot Design Overview

The Rclet Guardian is designed as a futuristic bot mascot inspired by Bangladesh's flag colors and a police badge shape, representing security and trust for the gig platform.

### Visual Elements:

1. **Shield Shape**: The mascot uses a shield-like silhouette representing protection and security
2. **Bangladesh Colors**: 
   - Primary: Bangladesh green (#006A4E) 
   - Accent: Red circle core (#DC143C) inspired by the Bangladesh flag
3. **Futuristic Elements**:
   - Glowing green eyes (#00FF88) 
   - Metallic appearance with subtle shadows
   - Animated pulsing effects

### Size Variants:
- **Small (32x32)**: For status indicators and app bars
- **Medium (64x64)**: For control centers and widgets  
- **Large (120x120)**: For splash screens and empty states

### States:
- **Idle**: Gentle glow, steady green eyes - "watching" mode
- **Active**: Pulsing animation, bright eyes - "working" mode
- **Alert**: Rapid pulse, bright eyes - "attention needed" mode
- **Success**: Victory shine, bright steady green - "task completed"
- **Error**: Warning pulse, red eyes - "error detected"

### Usage Contexts:

1. **Splash Screen**: Large animated mascot with "Rclet Guardian is initializing..."
2. **Control Center Widget**: Medium mascot showing platform security status
3. **Agent Status Indicator**: Small mascot in app bar showing online status
4. **Empty States**: Large mascot with "No gigs yet—Rclet Guardian is watching"
5. **Loading States**: Active mascot with working animations

### Technical Implementation:

The mascot is implemented using Flutter's built-in widgets and decorations:
- Container with shield-shaped decoration
- Stack layout for layering elements  
- BoxShadow for glow effects
- TweenAnimationBuilder for animations
- Responsive sizing with ScreenUtil

### Fallback Support:
When the mascot asset is unavailable, the system gracefully falls back to a simple shield icon with the Bangladesh green color, maintaining brand consistency.

This design reinforces the platform's commitment to security while celebrating Bangladesh's national identity.