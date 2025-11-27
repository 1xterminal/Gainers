import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/weight_model.dart';

class WeightRepository {
	final SupabaseClient _client;

	WeightRepository(this._client);

	Future<void> addWeightLog(WeightLog log) async {
		final userId = _client.auth.currentUser?.id;
		if (userId == null) throw Exception('Cannot get userId, user may not logged in');

		final data = log.toJson();
		data['user_id'] = userId;

		await _client.from('weight_logs').insert(data);
	}

	Future<List<WeightLog>> getWeightLogs(DateTime date) async {
		final userId = _client.auth.currentUser?.id;
		if (userId == null) return [];

		final startOfDay = DateTime(date.year, date.month, date.day);
		final endOfDay = startOfDay.add(const Duration(days: 1));

		final response = await _client
			.from('weight_logs')
			.select()
			.eq('user_id', userId)
			.gte('created_at', startOfDay.toIso8601String())
			.lt('created_at', endOfDay.toIso8601String())
			.order('created_at', ascending: true);

		return (response as List).map((e) => WeightLog.fromJson(e)).toList();
	}

	Future<void> deleteWeightLog(int id) async {
		await _client.from('weight_logs').delete().eq('id', id);
	}

}