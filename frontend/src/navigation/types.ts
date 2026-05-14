import type { StackScreenProps } from '@react-navigation/stack';

export type RootStackParamList = {
  Main: undefined;
  Lists: undefined;
  Profile: undefined;
  ListDetail: {
    listId: string;
    listTitle: string;
    promptAddItem?: boolean;
  };
  Login: undefined;
  Register: undefined;
};

export type RootStackScreenProps<T extends keyof RootStackParamList> =
  StackScreenProps<RootStackParamList, T>;
