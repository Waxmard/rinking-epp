import React from 'react';
import { View, StyleSheet, ViewStyle } from 'react-native';
import { AppColors } from '../design-system/tokens';

export interface TierDistribution {
  S: number;
  A: number;
  B: number;
  C: number;
  D: number;
  F: number;
}

interface TierDistributionBarProps {
  distribution: TierDistribution;
  style?: ViewStyle;
  height?: number;
}

const TIERS = ['S', 'A', 'B', 'C', 'D', 'F'] as const;

export const TierDistributionBar: React.FC<TierDistributionBarProps> = ({
  distribution,
  style,
  height = 8,
}) => {
  const total = TIERS.reduce((sum, tier) => sum + distribution[tier], 0);

  if (total === 0) {
    return (
      <View style={[styles.container, { height }, style]}>
        <View style={[styles.segment, styles.empty, { flex: 1 }]} />
      </View>
    );
  }

  return (
    <View style={[styles.container, { height }, style]}>
      {TIERS.map((tier) => {
        const count = distribution[tier];
        if (count === 0) return null;

        return (
          <View
            key={tier}
            style={[
              styles.segment,
              {
                flex: count,
                backgroundColor:
                  AppColors.tierColors[
                    tier as keyof typeof AppColors.tierColors
                  ],
              },
            ]}
          />
        );
      })}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    borderRadius: 4,
    overflow: 'hidden',
  },
  segment: {
    height: '100%',
  },
  empty: {
    backgroundColor: AppColors.neutral[200],
  },
});
