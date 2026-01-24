import { api } from './api';

export type TierSet = 'good' | 'mid' | 'bad';

export interface Item {
  item_id: string;
  list_id: string;
  name: string;
  description: string | null;
  image_url: string | null;
  tier: string | null;
  rank: number | null;
  created_at: string;
  updated_at: string;
}

export interface ComparisonSession {
  session_id: string;
  list_id: string;
  item_a: Item;
  item_b: Item;
}

export interface CreateItemRequest {
  name: string;
  tier_set: TierSet;
  description?: string;
  image_url?: string;
}

export interface UpdateItemRequest {
  name?: string;
  description?: string;
}

export type CreateItemResponse = Item | ComparisonSession;

// Type guard to check if response is a ComparisonSession
export const isComparisonSession = (
  response: CreateItemResponse
): response is ComparisonSession => {
  return (
    'session_id' in response && 'item_a' in response && 'item_b' in response
  );
};

export const itemsService = {
  createItem: (
    listTitle: string,
    itemData: CreateItemRequest,
    token: string
  ): Promise<CreateItemResponse> =>
    api.post<CreateItemResponse>(
      `/api/items/?list_title=${encodeURIComponent(listTitle)}`,
      itemData,
      token
    ),

  updateItem: (
    itemId: string,
    itemData: UpdateItemRequest,
    token: string
  ): Promise<Item> =>
    api.put<Item>(`/api/items/items/${itemId}`, itemData, token),
};
