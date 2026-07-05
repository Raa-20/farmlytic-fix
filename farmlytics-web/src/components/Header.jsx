export default function Header({ username, pageTitle }) {
  return (
    <div className="bg-white px-6 h-16 shrink-0 flex items-center justify-between border-b border-gray-200">
      <h2 className="text-lg font-semibold text-gray-600">
        {pageTitle}
      </h2>
      <span className="text-gray-700 font-medium">
        Halo, {username} 👋
      </span>
    </div>
  );
}