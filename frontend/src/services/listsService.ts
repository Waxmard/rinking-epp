import { api } from './api';

export interface ListSimple {
  list_id: string;
  title: string;
  description: string | null;
  created_at: string;
  updated_at: string;
  item_count: number;
}

export const listsService = {
  getLists: (token: string) => api.get<ListSimple[]>('/api/lists/', token),
  createList: (name: string, description: string, token: string) =>
    api.post<ListSimple>(
      `/api/lists/?name=${encodeURIComponent(
        name
      )}&description=${encodeURIComponent(description)}`,
      undefined,
      token
    ),
};
